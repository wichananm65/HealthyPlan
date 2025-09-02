import 'package:flutter/material.dart';
import 'package:healthy_plan/drawer.dart';
import 'package:healthy_plan/services/menu_service.dart';

class TodaySummaryPage extends StatefulWidget {
  final List<MenuModel> breakfastFoods;
  final List<MenuModel> lunchFoods;
  final List<MenuModel> dinnerFoods;

  const TodaySummaryPage({
    super.key,
    required this.breakfastFoods,
    required this.lunchFoods,
    required this.dinnerFoods,
  });

  @override
  State<TodaySummaryPage> createState() => _TodaySummaryPageState();
}

class _TodaySummaryPageState extends State<TodaySummaryPage> {
  final double recommendedCaloriesLimit = 2000.0;
  final double recommendedSugarLimit =
      50.0; // แนะนำไม่เกิน 50g ต่อวัน สำหรับผู้ป่วยเบาหวาน

  double get totalCalories {
    double total = 0.0;
    total += widget.breakfastFoods.fold(
      0.0,
      (sum, food) => sum + food.calories,
    );
    total += widget.lunchFoods.fold(0.0, (sum, food) => sum + food.calories);
    total += widget.dinnerFoods.fold(0.0, (sum, food) => sum + food.calories);
    return total;
  }

  double get totalSugar {
    double total = 0.0;
    total += widget.breakfastFoods.fold(
      0.0,
      (sum, food) => sum + food.sugarContent,
    );
    total += widget.lunchFoods.fold(
      0.0,
      (sum, food) => sum + food.sugarContent,
    );
    total += widget.dinnerFoods.fold(
      0.0,
      (sum, food) => sum + food.sugarContent,
    );
    return total;
  }

  double getMealCalories(List<MenuModel> foods) {
    return foods.fold(0.0, (sum, food) => sum + food.calories);
  }

  double getMealSugar(List<MenuModel> foods) {
    return foods.fold(0.0, (sum, food) => sum + food.sugarContent);
  }

  Color _getCaloriesStatusColor(double amount) {
    if (amount <= recommendedCaloriesLimit * 0.7) {
      return Colors.green;
    } else if (amount <= recommendedCaloriesLimit) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color _getSugarStatusColor(double amount) {
    if (amount <= recommendedSugarLimit * 0.6) {
      return Colors.green;
    } else if (amount <= recommendedSugarLimit) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getCaloriesStatusText(double amount) {
    if (amount <= recommendedCaloriesLimit * 0.7) {
      return 'ดี';
    } else if (amount <= recommendedCaloriesLimit) {
      return 'ปานกลาง';
    } else {
      return 'เกิน';
    }
  }

  String _getSugarStatusText(double amount) {
    if (amount <= recommendedSugarLimit * 0.6) {
      return 'ปลอดภัย';
    } else if (amount <= recommendedSugarLimit) {
      return 'ระวัง';
    } else {
      return 'อันตราย';
    }
  }

  bool get hasAnyFood {
    return widget.breakfastFoods.isNotEmpty ||
        widget.lunchFoods.isNotEmpty ||
        widget.dinnerFoods.isNotEmpty;
  }

  Widget _buildMealCard(String mealName, String emoji, List<MenuModel> foods) {
    double mealCalories = getMealCalories(foods);
    double mealSugar = getMealSugar(foods);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                mealName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${mealCalories.toStringAsFixed(0)} kcal',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${mealSugar.toStringAsFixed(1)} g',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (foods.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  foods.map((food) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Expanded(
                            child: Text(
                              food.foodName,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${food.calories} kcal',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${food.sugarContent.toStringAsFixed(1)} g',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            )
          else
            const Text(
              'ยังไม่มีรายการอาหาร',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }

  String getDailyRecommendation() {
    String caloriesStatus = _getCaloriesStatusText(totalCalories);
    String sugarStatus = _getSugarStatusText(totalSugar);

    if (sugarStatus == 'อันตราย') {
      return '🚨 ระดับน้ำตาลเกินขีดจำกัดมาก - อันตรายสำหรับผู้ป่วยเบาหวาน!\n'
          '• หลีกเลี่ยงอาหารหวานและผลไม้หวานที่เหลือในวันนี้\n'
          '• ดื่มน้ำเปล่ามากๆ และออกกำลังกายเบาๆ\n'
          '• ตรวจวัดระดับน้ำตาลในเลือดบ่อยขึ้น';
    } else if (sugarStatus == 'ระวัง') {
      return '⚠️ ระดับน้ำตาลเข้าใกล้ขีดจำกัด\n'
          '• ควบคุมอาหารหวานในมื้อต่อไปอย่างเข้มงวด\n'
          '• เลือกอาหารที่มีน้ำตาลต่ำ\n'
          '• เพิ่มการออกกำลังกายเบาๆ';
    } else if (caloriesStatus == 'เกิน') {
      return '⚠️ พลังงานเกินแนะนำ แต่ระดับน้ำตาลยังดี\n'
          '• ลดมื้อเย็นหรือขนม\n'
          '• เลือกอาหารโปรตีนและผักใบเขียว\n'
          '• เพิ่มกิจกรรมเผาผลาญพลังงาน';
    } else {
      return '✅ ดีเยี่ยม! ทั้งพลังงานและระดับน้ำตาลอยู่ในเกณฑ์ที่เหมาะสม\n'
          '• รักษาระดับนี้ต่อไป\n'
          '• ดื่มน้ำเปล่าเพียงพอ\n'
          '• พักผ่อนให้เพียงพอ';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('สรุปแผนวันนี้'),
      ),
      drawer: MyDrawer(),
      body:
          !hasAnyFood
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant_menu, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'ยังไม่มีแผนอาหารวันนี้',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'เริ่มเพิ่มรายการอาหารในแผนของคุณ',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards Row
                    Row(
                      children: [
                        // Calories Summary
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade100,
                                  Colors.orange.shade50,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.local_fire_department,
                                  size: 30,
                                  color: Colors.orange,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'พลังงานรวม',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '${totalCalories.toStringAsFixed(0)} kcal',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _getCaloriesStatusColor(
                                      totalCalories,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'สถานะ: ${_getCaloriesStatusText(totalCalories)}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _getCaloriesStatusColor(
                                      totalCalories,
                                    ),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: (totalCalories /
                                          recommendedCaloriesLimit)
                                      .clamp(0.0, 1.0),
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getCaloriesStatusColor(totalCalories),
                                  ),
                                  minHeight: 6,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Sugar Summary
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade100,
                                  Colors.blue.shade50,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.water_drop,
                                  size: 30,
                                  color: Colors.blue,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'น้ำตาลรวม',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '${totalSugar.toStringAsFixed(1)} g',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _getSugarStatusColor(totalSugar),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'สถานะ: ${_getSugarStatusText(totalSugar)}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _getSugarStatusColor(totalSugar),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: (totalSugar / recommendedSugarLimit)
                                      .clamp(0.0, 1.0),
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getSugarStatusColor(totalSugar),
                                  ),
                                  minHeight: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'รายละเอียดตามมื้อ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1AA916),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildMealCard('อาหารเช้า', '🍳', widget.breakfastFoods),
                    _buildMealCard('อาหารกลางวัน', '🍛', widget.lunchFoods),
                    _buildMealCard('อาหารเย็น', '🍲', widget.dinnerFoods),

                    const SizedBox(height: 24),

                    // Recommendation / Tips
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.health_and_safety,
                                color: Colors.green.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'คำแนะนำสำหรับผู้ป่วยเบาหวาน',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            getDailyRecommendation(),
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Additional info for diabetics
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'ข้อมูลสำคัญ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '• แนะนำพลังงานต่อวัน: ${recommendedCaloriesLimit.toStringAsFixed(0)} kcal\n'
                            '• แนะนำน้ำตาลต่อวัน: ไม่เกิน ${recommendedSugarLimit.toStringAsFixed(0)} g\n'
                            '• ตรวจระดับน้ำตาลในเลือดก่อนและหลังอาหาร\n'
                            '• ออกกำลังกายสม่ำเสมอ 30 นาทีต่อวัน',
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
