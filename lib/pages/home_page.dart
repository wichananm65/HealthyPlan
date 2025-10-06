// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:healthy_plan/pages/summary.dart';
import 'package:healthy_plan/drawer.dart';
import 'package:healthy_plan/services/auto_plan_service.dart';
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

  Future<void> _autoPlan() async {
    _showPlanSelectionDialog();
  }

  void _showPlanSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'เลือกประเภทแผนอาหาร',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'เลือกแผนอาหารที่เหมาะสมกับเป้าหมายของคุณ',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildPlanOption(
                context,
                PlanType.sugarControl,
                '🩺 แผนควบคุมน้ำตาล',
                'เหมาะสำหรับผู้ป่วยเบาหวานหรือต้องการควบคุมระดับน้ำตาล',
                Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildPlanOption(
                context,
                PlanType.weightLoss,
                '⚖️ แผนลดความอ้วน',
                'เหมาะสำหรับผู้ที่ต้องการลดน้ำหนักอย่างปลอดภัย',
                Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildPlanOption(
                context,
                PlanType.muscleBuild,
                '💪 แผนเพิ่มกล้ามเนื้อ',
                'เหมาะสำหรับผู้ที่ออกกำลังกายและต้องการเพิ่มกล้ามเนื้อ',
                Colors.green,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlanOption(
    BuildContext context,
    PlanType planType,
    String planName,
    String description,
    Color color,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          elevation: 0,
        ),
        onPressed: () async {
          Navigator.of(context).pop();
          await _executePlan(planType);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              planName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _executePlan(PlanType planType) async {
    setState(() => isLoading = true);

    await AutoPlanService.generatePlanAndSave(planType);
    await loadData();

    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 48),
                const SizedBox(height: 16),
                Text(
                  'จัด${AutoPlanService.getPlanName(planType)}เรียบร้อยแล้ว',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AutoPlanService.getPlanDescription(planType),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'ตกลง',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 40),
            FoodTable(
              breakfastFoods: breakfastMenus,
              lunchFoods: lunchMenus,
              dinnerFoods: dinnerMenus,
              onRefresh: loadData,
              isLoading: isLoading,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(
                        Icons.auto_fix_high,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'วางแผนอัตโนมัติ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: _autoPlan,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.analytics, color: Colors.white),
                      label: const Text(
                        'สรุปแผนวันนี้',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FoodTable extends StatelessWidget {
  const FoodTable({
    super.key,
    required this.breakfastFoods,
    required this.lunchFoods,
    required this.dinnerFoods,
    required this.onRefresh,
    required this.isLoading,
  });

  final List<MenuModel> breakfastFoods;
  final List<MenuModel> lunchFoods;
  final List<MenuModel> dinnerFoods;
  final VoidCallback onRefresh;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
  final String mealType;
  final VoidCallback onRefresh;

  @override
  State<FoodCardList> createState() => _FoodCardListState();
}

class _FoodCardListState extends State<FoodCardList> {
  Future<void> _removeFromMeal(MenuModel food) async {
    try {
      await UserService().removeFromMeal(widget.mealType, food.id);

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
                    Navigator.of(context).pop();
                  },
                  child: const Text('ตกลง'),
                ),
              ],
            );
          },
        );

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
