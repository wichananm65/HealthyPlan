import 'package:flutter/material.dart';
import 'package:healthy_plan/pages/summary.dart';
import 'package:healthy_plan/drawer.dart';
import 'package:healthy_plan/services/user_service.dart';
import 'package:healthy_plan/services/menu_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final userService = UserService();
  final menuService = MenuService();

  List<MenuModel> breakfastMenus = [];
  List<MenuModel> lunchMenus = [];
  List<MenuModel> dinnerMenus = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    await userService.loadUser();
    await menuService.loadAllMenus();

    // แปลง menuId -> MenuModel
    breakfastMenus =
        userService.breakfast
            .map((id) => menuService.getMenuById(id))
            .whereType<MenuModel>()
            .toList();

    lunchMenus =
        userService.lunch
            .map((id) => menuService.getMenuById(id))
            .whereType<MenuModel>()
            .toList();

    dinnerMenus =
        userService.dinner
            .map((id) => menuService.getMenuById(id))
            .whereType<MenuModel>()
            .toList();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Healthy Plan'),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        backgroundColor: Colors.green,
      ),
      drawer: MyDrawer(),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    FoodTable(
                      breakfastFoods: breakfastMenus,
                      lunchFoods: lunchMenus,
                      dinnerFoods: dinnerMenus,
                      onRefresh: loadData,
                    ),
                    const SizedBox(height: 20),
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => TodaySummaryPage(
                                    breakfastFoods: breakfastMenus,
                                    lunchFoods: lunchMenus,
                                    dinnerFoods: dinnerMenus,
                                  ),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.analytics, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'สรุปแผนวันนี้',
                              style: TextStyle(
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
              ),
    );
  }
}

/// Table ของอาหาร
class FoodTable extends StatelessWidget {
  const FoodTable({
    super.key,
    required this.breakfastFoods,
    required this.lunchFoods,
    required this.dinnerFoods,
    required this.onRefresh,
  });

  final List<MenuModel> breakfastFoods;
  final List<MenuModel> lunchFoods;
  final List<MenuModel> dinnerFoods;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 3, color: Colors.lightGreen),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Table(
        border: TableBorder.symmetric(
          inside: const BorderSide(width: 3, color: Colors.lightGreen),
        ),
        columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(3)},
        children: [
          TableRow(
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  '🍳 อาหารเช้า ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: FoodCardList(
                  foods: breakfastFoods,
                  mealType: 'breakfast',
                  onRefresh: onRefresh,
                ),
              ),
            ],
          ),
          TableRow(
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  '🍛 อาหารกลางวัน',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: FoodCardList(
                  foods: lunchFoods,
                  mealType: 'lunch',
                  onRefresh: onRefresh,
                ),
              ),
            ],
          ),
          TableRow(
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  '🍲 อาหารเย็น',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: FoodCardList(
                  foods: dinnerFoods,
                  mealType: 'dinner',
                  onRefresh: onRefresh,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FoodCardList extends StatefulWidget {
  const FoodCardList({
    super.key,
    required this.foods,
    required this.mealType,
    required this.onRefresh,
  });

  final List<MenuModel> foods;
  final String mealType; // 'breakfast', 'lunch', หรือ 'dinner'
  final VoidCallback onRefresh;

  @override
  State<FoodCardList> createState() => _FoodCardListState();
}

class _FoodCardListState extends State<FoodCardList> {
  Future<void> _removeFromMeal(MenuModel food) async {
    try {
      await UserService().removeFromMeal(widget.mealType, food.id);

      // แสดง Dialog ยืนยันว่าลบเสร็จ
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'สำเร็จ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              content: Text('ลบ "${food.foodName}" ออกจากมื้ออาหารแล้ว'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // ปิด dialog
                  },
                  child: const Text('ตกลง'),
                ),
              ],
            );
          },
        );

        // รีเฟรชข้อมูลหลังจากปิด dialog
        widget.onRefresh();
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'เกิดข้อผิดพลาด',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('ปิด'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _showDeleteConfirmation(MenuModel food) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'ยืนยันการลบ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'คุณต้องการลบ "${food.foodName}" ออกจากมื้ออาหารนี้หรือไม่?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removeFromMeal(food);
              },
              child: const Text('ลบ', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.foods.isEmpty) {
      return const Text(
        'ยังไม่มีรายการอาหาร',
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          widget.foods.map((food) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200, width: 1),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Text(
                          food.foodName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${food.calories} kcal',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${food.sugarContent.toStringAsFixed(1)} g',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // ปุ่มลบที่มุมขวาบน (minimal design)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => _showDeleteConfirmation(food),
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
