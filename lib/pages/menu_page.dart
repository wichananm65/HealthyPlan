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

  void _showMealSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'เลือกมื้ออาหาร',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1AA916),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'เลือกมื้ออาหารที่ต้องการเพิ่ม "${widget.menu.foodName}"',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              _buildMealOption(
                context,
                'มื้อเช้า',
                Icons.breakfast_dining,
                'breakfast',
              ),
              const SizedBox(height: 12),
              _buildMealOption(
                context,
                'มื้อกลางวัน',
                Icons.lunch_dining,
                'lunch',
              ),
              const SizedBox(height: 12),
              _buildMealOption(
                context,
                'มื้อเย็น',
                Icons.dinner_dining,
                'dinner',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMealOption(
    BuildContext context,
    String mealName,
    IconData icon,
    String mealType,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[50],
          foregroundColor: Colors.green[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.green[200]!),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () async {
          Navigator.of(context).pop(); // ปิด dialog ก่อน
          await _addToMeal(mealType, mealName);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 8),
            Text(
              mealName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToMeal(String mealType, String mealName) async {
    try {
      await UserService().addToMeal(mealType, widget.menu.id);

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('สำเร็จ', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              'เพิ่ม "${widget.menu.foodName}" ใน $mealName เรียบร้อยแล้ว',
              style: const TextStyle(fontSize: 14),
            ),
          );
        },
      );

      Future.delayed(const Duration(milliseconds: 1500), () {});
    } catch (e) {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: const [
                Icon(Icons.error, color: Colors.red, size: 28),
                SizedBox(width: 8),
                Text(
                  'ข้อผิดพลาด',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              'เกิดข้อผิดพลาด: ${e.toString()}',
              style: const TextStyle(fontSize: 14),
            ),
          );
        },
      );
    }
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
                image:
                    widget.menu.picture != null
                        ? DecorationImage(
                          image: NetworkImage(widget.menu.picture!),
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                // Calories display
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              color: Colors.orange[700],
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'พลังงาน',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.menu.calories} kcal',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Sugar display
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.water_drop,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'น้ำตาล',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.menu.sugarContent.toStringAsFixed(1)} g',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Add to meal button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1AA916),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 3,
                ),
                onPressed: _showMealSelectionDialog,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'นำเข้ามื้ออาหาร',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

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
