import 'package:flutter/material.dart';
import 'package:healthy_plan/drawer.dart';
import 'package:healthy_plan/services/menu_service.dart';
import 'package:healthy_plan/services/user_service.dart';

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
  final double recommendedSugarLimit = 50.0;

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

  double get bmi {
    final height = UserService().getHeight() / 100;
    final weight = UserService().getWeight();
    if (height <= 0) return 0;
    return weight / (height * height);
  }

  Color _getBmiStatusColor(double bmiValue) {
    if (bmiValue < 18.5) return Colors.orange;
    if (bmiValue < 25) return Colors.green;
    if (bmiValue < 30) return Colors.orange;
    return Colors.red;
  }

  String _getBmiStatusText(double bmiValue) {
    if (bmiValue < 18.5) return 'น้ำหนักต่ำ';
    if (bmiValue < 25) return 'ปกติ';
    if (bmiValue < 30) return 'น้ำหนักเกิน';
    return 'อ้วนมาก';
  }

  double getRecommendedCalories() {
    final age = UserService().getAge();
    final bmiValue = bmi;

    if (age <= 30) {
      if (bmiValue < 18.5) return 2200;
      if (bmiValue < 25) return 2000;
      if (bmiValue < 30) return 1800;
      return 1600;
    } else if (age <= 50) {
      if (bmiValue < 18.5) return 2000;
      if (bmiValue < 25) return 1800;
      if (bmiValue < 30) return 1600;
      return 1400;
    } else {
      if (bmiValue < 18.5) return 1800;
      if (bmiValue < 25) return 1600;
      if (bmiValue < 30) return 1400;
      return 1200;
    }
  }

  Color _getCaloriesStatusColor(double amount) {
    final recommendedCalories = getRecommendedCalories();
    if (amount <= recommendedCalories * 0.7) return Colors.green;
    if (amount <= recommendedCalories) return Colors.orange;
    return Colors.red;
  }

  Color _getSugarStatusColor(double amount) {
    if (amount <= recommendedSugarLimit * 0.6) return Colors.green;
    if (amount <= recommendedSugarLimit) return Colors.orange;
    return Colors.red;
  }

  String _getCaloriesStatusText(double amount) {
    final recommendedCalories = getRecommendedCalories();
    if (amount <= recommendedCalories * 0.7) return 'ดี';
    if (amount <= recommendedCalories) return 'ปานกลาง';
    return 'เกิน';
  }

  String _getSugarStatusText(double amount) {
    if (amount <= recommendedSugarLimit * 0.6) return 'ปลอดภัย';
    if (amount <= recommendedSugarLimit) return 'ระวัง';
    return 'อันตราย';
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
    double userBmi = bmi;

    String bmiAdvice = '';
    if (userBmi < 18.5) {
      bmiAdvice = '💡 BMI ต่ำกว่าปกติ ควรเพิ่มพลังงานและโปรตีน';
    } else if (userBmi < 25) {
      bmiAdvice = '💡 BMI อยู่ในเกณฑ์ปกติ รักษาระดับพลังงานให้เหมาะสม';
    } else if (userBmi < 30) {
      bmiAdvice = '💡 BMI สูงกว่าปกติ ลดอาหารหวาน/แป้ง';
    } else {
      bmiAdvice = '💡 BMI สูงมาก ควรควบคุมน้ำตาลและไขมันสูง';
    }

    if (sugarStatus == 'อันตราย') {
      return '🚨 ระดับน้ำตาลเกินขีดจำกัด!\n$bmiAdvice';
    } else if (sugarStatus == 'ระวัง') {
      return '⚠️ ระดับน้ำตาลเข้าใกล้ขีดจำกัด\n$bmiAdvice';
    } else if (caloriesStatus == 'เกิน') {
      return '⚠️ พลังงานเกินแนะนำ\n$bmiAdvice';
    } else {
      return '✅ ดีเยี่ยม! ทั้งพลังงานและน้ำตาลอยู่ในเกณฑ์\n$bmiAdvice';
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
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'พลังงานรวม',
                            totalCalories,
                            _getCaloriesStatusText(totalCalories),
                            _getCaloriesStatusColor(totalCalories),
                            Icons.local_fire_department,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            'น้ำตาลรวม',
                            totalSugar,
                            _getSugarStatusText(totalSugar),
                            _getSugarStatusColor(totalSugar),
                            Icons.water_drop,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            'BMI',
                            bmi,
                            _getBmiStatusText(bmi),
                            _getBmiStatusColor(bmi),
                            Icons.monitor_weight,
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
                                color: Colors.green.shade400,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'คำแนะนำสำหรับผู้ป่วยเบาหวาน',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade400,
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
                  ],
                ),
              ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double value,
    String statusText,
    Color statusColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.2), statusColor.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: statusColor),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${value.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'สถานะ: $statusText',
            style: TextStyle(
              fontSize: 14,
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
