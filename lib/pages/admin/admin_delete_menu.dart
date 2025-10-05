import 'package:flutter/material.dart';
import 'package:healthy_plan/services/menu_service.dart';

class AdminDeleteMenuPage extends StatefulWidget {
  const AdminDeleteMenuPage({super.key});

  @override
  State<AdminDeleteMenuPage> createState() => _AdminDeleteMenuPageState();
}

class _AdminDeleteMenuPageState extends State<AdminDeleteMenuPage> {
  final MenuService _menuService = MenuService();
  List<MenuModel> _allMenus = [];
  List<MenuModel> _filteredMenus = [];
  Set<String> _selectedMenuIds = {};
  bool _isLoading = true;
  bool _isDeleting = false;
  bool _selectAll = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMenus();
    _searchController.addListener(_applySearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMenus() async {
    setState(() => _isLoading = true);
    try {
      final menus = await _menuService.loadAllMenus(forceRefresh: true);
      setState(() {
        _allMenus = menus;
        _filteredMenus = menus;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applySearch() {
    String query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredMenus = _allMenus;
      } else {
        _filteredMenus =
            _allMenus.where((menu) {
              return menu.foodName.toLowerCase().contains(query) ||
                  menu.benefit.toLowerCase().contains(query);
            }).toList();
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      if (_selectAll) {
        _selectedMenuIds = _filteredMenus.map((m) => m.id).toSet();
      } else {
        _selectedMenuIds.clear();
      }
    });
  }

  void _toggleSelection(String menuId) {
    setState(() {
      if (_selectedMenuIds.contains(menuId)) {
        _selectedMenuIds.remove(menuId);
      } else {
        _selectedMenuIds.add(menuId);
      }
      _selectAll = _selectedMenuIds.length == _filteredMenus.length;
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedMenuIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกเมนูที่ต้องการลบ'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.red, size: 28),
                SizedBox(width: 8),
                Text(
                  'ยืนยันการลบ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              'คุณต้องการลบเมนู ${_selectedMenuIds.length} รายการ หรือไม่?\n\nการดำเนินการนี้ไม่สามารถย้อนกลับได้',
              style: const TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'ยกเลิก',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('ลบ', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      int successCount = 0;
      int failCount = 0;

      for (String menuId in _selectedMenuIds) {
        try {
          await _menuService.deleteMenu(menuId);
          successCount++;
        } catch (e) {
          failCount++;
        }
      }

      setState(() {
        _selectedMenuIds.clear();
        _selectAll = false;
      });

      await _loadMenus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ลบเมนูสำเร็จ $successCount รายการ${failCount > 0 ? ', ล้มเหลว $failCount รายการ' : ''}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isDeleting = false);
  }

  Future<void> _deleteAll() async {
    if (_allMenus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่มีเมนูให้ลบ'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.delete_forever, color: Colors.red, size: 32),
                SizedBox(width: 8),
                Text(
                  '⚠️ ลบทั้งหมด',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            content: Text(
              'คุณแน่ใจหรือไม่ที่จะลบเมนูทั้งหมด ${_allMenus.length} รายการ?\n\n⚠️ การดำเนินการนี้จะลบเมนูทั้งหมดและไม่สามารถกู้คืนได้!',
              style: const TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'ยกเลิก',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'ลบทั้งหมด',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      int successCount = 0;
      int failCount = 0;

      for (MenuModel menu in _allMenus) {
        try {
          await _menuService.deleteMenu(menu.id);
          successCount++;
        } catch (e) {
          failCount++;
        }
      }

      setState(() {
        _selectedMenuIds.clear();
        _selectAll = false;
      });

      await _loadMenus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ลบเมนูสำเร็จ $successCount รายการ${failCount > 0 ? ', ล้มเหลว $failCount รายการ' : ''}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isDeleting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ลบเมนู'),
        backgroundColor: Colors.red.shade700,
        elevation: 0,
        actions: [
          if (_selectedMenuIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'ลบที่เลือก',
              onPressed: _isDeleting ? null : _deleteSelected,
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.red),
              )
              : Column(
                children: [
                  // Search and Action Bar
                  Container(
                    color: Colors.red.shade50,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'ค้นหาเมนู',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade700,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed:
                                    _isDeleting ? null : _toggleSelectAll,
                                icon: Icon(
                                  _selectAll
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                ),
                                label: Text(
                                  _selectAll
                                      ? 'ยกเลิกเลือกทั้งหมด'
                                      : 'เลือกทั้งหมด',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade700,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _isDeleting ? null : _deleteAll,
                                icon: const Icon(Icons.delete_forever),
                                label: const Text('ลบทั้งหมด'),
                              ),
                            ),
                          ],
                        ),
                        if (_selectedMenuIds.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info,
                                  color: Colors.blue.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'เลือกแล้ว ${_selectedMenuIds.length} รายการ',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Menu List
                  Expanded(
                    child:
                        _filteredMenus.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.restaurant_menu,
                                    size: 80,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'ไม่มีเมนู',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredMenus.length,
                              itemBuilder: (context, index) {
                                final menu = _filteredMenus[index];
                                final isSelected = _selectedMenuIds.contains(
                                  menu.id,
                                );

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color:
                                          isSelected
                                              ? Colors.red
                                              : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: Checkbox(
                                      value: isSelected,
                                      onChanged:
                                          _isDeleting
                                              ? null
                                              : (value) =>
                                                  _toggleSelection(menu.id),
                                      activeColor: Colors.red,
                                    ),
                                    title: Text(
                                      menu.foodName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          menu.benefit.length > 50
                                              ? '${menu.benefit.substring(0, 50)}...'
                                              : menu.benefit,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                '${menu.calories} kcal',
                                                style: TextStyle(
                                                  color: Colors.orange.shade700,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                '${menu.sugarContent.toStringAsFixed(1)} g',
                                                style: TextStyle(
                                                  color: Colors.blue.shade700,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed:
                                          _isDeleting
                                              ? null
                                              : () => _deleteSingle(menu),
                                    ),
                                    onTap: () => _toggleSelection(menu.id),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
      floatingActionButton:
          _selectedMenuIds.isNotEmpty
              ? FloatingActionButton.extended(
                onPressed: _isDeleting ? null : _deleteSelected,
                backgroundColor: Colors.red,
                icon:
                    _isDeleting
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Icon(Icons.delete),
                label: Text(
                  _isDeleting
                      ? 'กำลังลบ...'
                      : 'ลบ ${_selectedMenuIds.length} รายการ',
                ),
              )
              : null,
    );
  }

  Future<void> _deleteSingle(MenuModel menu) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.red, size: 28),
                SizedBox(width: 8),
                Text(
                  'ยืนยันการลบ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              'คุณต้องการลบเมนู "${menu.foodName}" หรือไม่?\n\nการดำเนินการนี้ไม่สามารถย้อนกลับได้',
              style: const TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'ยกเลิก',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('ลบ', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      await _menuService.deleteMenu(menu.id);
      await _loadMenus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ลบเมนูเรียบร้อยแล้ว'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isDeleting = false);
  }
}
