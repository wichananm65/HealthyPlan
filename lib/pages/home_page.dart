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
  });

  final List<MenuModel> breakfastFoods;
  final List<MenuModel> lunchFoods;
  final List<MenuModel> dinnerFoods;

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
                child: FoodCardList(foods: breakfastFoods),
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
                child: FoodCardList(foods: lunchFoods),
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
                child: FoodCardList(foods: dinnerFoods), // ชื่อถูกต้อง
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FoodCardList extends StatelessWidget {
  const FoodCardList({super.key, required this.foods});

  final List<MenuModel> foods;

  @override
  Widget build(BuildContext context) {
    if (foods.isEmpty) {
      return const Text(
        'ยังไม่มีรายการอาหาร',
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          foods.map((food) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      food.foodName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
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
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${food.calories} kcal',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
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
