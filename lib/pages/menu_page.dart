import 'package:flutter/material.dart';
import 'package:healthy_plan/services/menu_service.dart';

class MenuPage extends StatelessWidget {
  final MenuModel menu;

  const MenuPage({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.green, title: Text(menu.foodName)),
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
