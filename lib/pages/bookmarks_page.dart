import 'package:flutter/material.dart';
import 'package:healthy_plan/drawer.dart';
import 'package:healthy_plan/services/menu_service.dart';
import 'package:healthy_plan/services/user_service.dart';
import 'menu_page.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key, required this.title});

  final String title;

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  final MenuService _menuService = MenuService();
  List<MenuModel> _allMenus = [];
  List<MenuModel> _favouriteMenus = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await UserService().loadUser();
    _allMenus = await _menuService.loadAllMenus();

    _favouriteMenus =
        _allMenus.where((menu) {
          return UserService().favouriteMenus.contains(menu.id);
        }).toList();

    setState(() {
      _isLoading = false;
    });
  }

  void _toggleFavourite(MenuModel menu) async {
    if (UserService().favouriteMenus.contains(menu.id)) {
      await UserService().removeFavourite(menu.id);
    } else {
      await UserService().addFavourite(menu.id);
    }
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(widget.title),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      drawer: MyDrawer(),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
              : _favouriteMenus.isEmpty
              ? const Center(child: Text('คุณยังไม่มีรายการโปรด'))
              : ListView.builder(
                itemCount: _favouriteMenus.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final menu = _favouriteMenus[index];
                  final isFavourite = UserService().favouriteMenus.contains(
                    menu.id,
                  );

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
                      trailing: IconButton(
                        icon: Icon(
                          isFavourite
                              ? Icons.favorite
                              : Icons.favorite_border_outlined,
                          color: Colors.red,
                          size: 25,
                        ),
                        onPressed: () => _toggleFavourite(menu),
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
    );
  }
}
