import 'package:flutter/material.dart';
import 'package:healthy_plan/drawer.dart';
import 'package:healthy_plan/services/menu_service.dart';
import 'package:healthy_plan/services/user_service.dart';
import 'menu_page.dart';

enum FilterOption { kcalAsc, kcalDesc, sugarAsc, sugarDesc }

class MenusPage extends StatefulWidget {
  const MenusPage({super.key});

  @override
  State<MenusPage> createState() => _MenusPageState();
}

class _MenusPageState extends State<MenusPage> {
  final MenuService _menuService = MenuService();
  List<MenuModel> _menus = [];
  List<MenuModel> _filteredMenus = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  FilterOption? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_applySearch);
  }

  Future<void> _loadData() async {
    await UserService().loadUser();
    final menus = await _menuService.loadAllMenus();
    setState(() {
      _menus = menus;
      _filteredMenus = menus;
      _isLoading = false;
    });
  }

  void _applySearch() {
    String query = _searchController.text.trim().toLowerCase();
    List<MenuModel> results =
        _menus.where((menu) {
          return menu.foodName.toLowerCase().contains(query);
        }).toList();

    if (_selectedFilter != null) {
      results = _applyFilter(results, _selectedFilter!);
    }

    setState(() {
      _filteredMenus = results;
    });
  }

  List<MenuModel> _applyFilter(List<MenuModel> menus, FilterOption filter) {
    List<MenuModel> sorted = List.from(menus);
    switch (filter) {
      case FilterOption.kcalAsc:
        sorted.sort((a, b) => a.calories.compareTo(b.calories));
        break;
      case FilterOption.kcalDesc:
        sorted.sort((a, b) => b.calories.compareTo(a.calories));
        break;
      case FilterOption.sugarAsc:
        sorted.sort((a, b) => a.sugarContent.compareTo(b.sugarContent));
        break;
      case FilterOption.sugarDesc:
        sorted.sort((a, b) => b.sugarContent.compareTo(a.sugarContent));
        break;
    }
    return sorted;
  }

  void _onFilterSelected(FilterOption option) {
    _selectedFilter = option;
    _applySearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เมนู'),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        backgroundColor: Colors.green,
      ),
      drawer: MyDrawer(),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
              : Column(
                children: [
                  // Search + Filter
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'ค้นหาเมนู',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.green[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<FilterOption>(
                          icon: const Icon(Icons.filter_list),
                          onSelected: _onFilterSelected,
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: FilterOption.kcalAsc,
                                  child: Text('แคลอรี่ น้อย → มาก'),
                                ),
                                const PopupMenuItem(
                                  value: FilterOption.kcalDesc,
                                  child: Text('แคลอรี่ มาก → น้อย'),
                                ),
                                const PopupMenuItem(
                                  value: FilterOption.sugarAsc,
                                  child: Text('น้ำตาล น้อย → มาก'),
                                ),
                                const PopupMenuItem(
                                  value: FilterOption.sugarDesc,
                                  child: Text('น้ำตาล มาก → น้อย'),
                                ),
                              ],
                        ),
                      ],
                    ),
                  ),

                  // Menu list
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredMenus.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final menu = _filteredMenus[index];
                        final isFavourite = UserService().favouriteMenus
                            .contains(menu.id);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green[200]!),
                                image:
                                    menu.picture != null
                                        ? DecorationImage(
                                          image: NetworkImage(menu.picture!),
                                          fit: BoxFit.cover,
                                        )
                                        : null,
                              ),
                            ),
                            title: Text(
                              menu.foodName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  menu.benefit.length > 50
                                      ? '${menu.benefit.substring(0, 50)}...'
                                      : menu.benefit,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[50],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${menu.calories} kcal',
                                        style: TextStyle(
                                          color: Colors.orange[700],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${menu.sugarContent.toStringAsFixed(1)} g',
                                        style: TextStyle(
                                          color: Colors.blue[700],
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
                              icon: Icon(
                                isFavourite
                                    ? Icons.favorite
                                    : Icons.favorite_border_outlined,
                                color: Colors.red,
                                size: 25,
                              ),
                              onPressed: () async {
                                if (isFavourite) {
                                  await UserService().removeFavourite(menu.id);
                                } else {
                                  await UserService().addFavourite(menu.id);
                                }
                                setState(() {});
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MenuPage(menu: menu),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
