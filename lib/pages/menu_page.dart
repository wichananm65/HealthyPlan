import 'package:flutter/material.dart';
import 'package:healthy_plan/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(const Menu());
}

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthy Plan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreenAccent),
      ),
      home: const MyMenuPage(title: 'เมนู'),
    );
  }
}

class MenuModel {
  final String id;
  final String benefit;
  final int calories;
  final String foodName;
  final String howTo;
  final String ingredient;
  final String? picture;

  MenuModel({
    required this.id,
    required this.benefit,
    required this.calories,
    required this.foodName,
    required this.howTo,
    required this.ingredient,
    this.picture,
  });

  factory MenuModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MenuModel(
      id: doc.id,
      benefit: data['benefit'] ?? '',
      calories: data['calories'] ?? 0,
      foodName: data['foodName'] ?? '',
      howTo: data['howTo'] ?? '',
      ingredient: (data['ingredient'] as List<dynamic>?)?.join(', ') ?? '',
      picture: data['picture'],
    );
  }
}

class MyMenuPage extends StatefulWidget {
  const MyMenuPage({super.key, required this.title});

  final String title;

  @override
  State<MyMenuPage> createState() => _MyMenuPageState();
}

class _MyMenuPageState extends State<MyMenuPage> {
  final TextEditingController _searchController = TextEditingController();
  List<MenuModel> _allMenus = [];
  List<MenuModel> _filteredMenus = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadMenuData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMenuData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection('menu')
              .orderBy('foodName')
              .get();

      List<MenuModel> menus =
          querySnapshot.docs
              .map((doc) => MenuModel.fromFirestore(doc))
              .toList();

      setState(() {
        _allMenus = menus;
        _filteredMenus = menus;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'เกิดข้อผิดพลาดในการโหลดข้อมูล: $e';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredMenus = _allMenus;
      } else {
        _filteredMenus =
            _allMenus.where((menu) {
              return menu.foodName.toLowerCase().contains(query) ||
                  menu.ingredient.toLowerCase().contains(query) ||
                  menu.benefit.toLowerCase().contains(query);
            }).toList();
      }
    });
  }

  void _showMenuDetail(MenuModel menu) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          menu.foodName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          '${menu.calories} kcal',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mock Image
                        Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Benefits
                        _buildDetailSection(
                          title: 'ประโยชน์',
                          content: menu.benefit,
                          icon: Icons.favorite,
                        ),
                        const SizedBox(height: 16),

                        // Ingredients
                        _buildDetailSection(
                          title: 'ส่วนผสม',
                          content: menu.ingredient,
                          icon: Icons.list,
                        ),
                        const SizedBox(height: 16),

                        // How to cook
                        _buildDetailSection(
                          title: 'วิธีทำ',
                          content: menu.howTo,
                          icon: Icons.book,
                        ),
                      ],
                    ),
                  ),
                ),

                // Close button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('ปิด', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(widget.title),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMenuData),
        ],
      ),
      drawer: MyDrawer(),
      body: Column(
        children: <Widget>[
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ค้นหาเมนู, ส่วนผสม, หรือประโยชน์...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.green),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 20,
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    )
                    : _error.isNotEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _error,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadMenuData,
                            child: const Text('ลองอีกครั้ง'),
                          ),
                        ],
                      ),
                    )
                    : _filteredMenus.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isNotEmpty
                                ? 'ไม่พบเมนูที่ค้นหา'
                                : 'ยังไม่มีเมนูในระบบ',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredMenus.length,
                      itemBuilder: (context, index) {
                        MenuModel menu = _filteredMenus[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
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
                              ),
                              child: const Icon(
                                Icons.restaurant,
                                color: Colors.green,
                                size: 30,
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
                              ],
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.green,
                              size: 16,
                            ),
                            onTap: () => _showMenuDetail(menu),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
