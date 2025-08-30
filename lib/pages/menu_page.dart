import 'package:flutter/material.dart';
import 'package:healthy_plan/drawer.dart';
import 'package:healthy_plan/services/menu_service.dart';
import 'package:healthy_plan/services/user_service.dart';

class MenuPage extends StatefulWidget {
  final MenuModel menu;

  const MenuPage({super.key, required this.menu});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late bool isFavourite;

  @override
  void initState() {
    super.initState();
    isFavourite = UserService().favouriteMenus.contains(widget.menu.id);
  }

  void toggleFavourite() async {
    if (isFavourite) {
      await UserService().removeFavourite(widget.menu.id);
    } else {
      await UserService().addFavourite(widget.menu.id);
    }
    setState(() {
      isFavourite = !isFavourite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(widget.menu.foodName),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavourite ? Icons.favorite : Icons.favorite_border_outlined,
              color: Colors.red,
              size: 28,
            ),
            onPressed: toggleFavourite,
          ),
        ],
      ),
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.restaurant, size: 50, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Benefits
            _buildDetailSection(
              title: 'ประโยชน์',
              content: widget.menu.benefit,
              icon: Icons.favorite,
            ),
            const SizedBox(height: 16),

            // Ingredients
            _buildDetailSection(
              title: 'ส่วนผสม',
              content: widget.menu.ingredient,
              icon: Icons.list,
            ),
            const SizedBox(height: 16),

            // How to cook
            _buildDetailSection(
              title: 'วิธีทำ',
              content: widget.menu.howTo,
              icon: Icons.book,
            ),
          ],
        ),
      ),
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
}
