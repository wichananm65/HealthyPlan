import 'package:flutter/material.dart';
import 'package:healthy_plan/drawer.dart';
import 'package:healthy_plan/services/menu_service.dart'; // import MenuModel

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
  final double recommendedLimit = 2000.0; // พลังงานแนะนำต่อวัน (kcal)

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

  double getMealCalories(List<MenuModel> foods) {
    return foods.fold(0.0, (sum, food) => sum + food.calories);
  }

  Color _getStatusColor(double amount) {
    if (amount <= recommendedLimit * 0.7) {
      return Colors.green;
    } else if (amount <= recommendedLimit) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getStatusText(double amount) {
    if (amount <= recommendedLimit * 0.7) {
      return 'ดี';
    } else if (amount <= recommendedLimit) {
      return 'ปานกลาง';
    } else {
      return 'เกิน';
    }
  }

  bool get hasAnyFood {
    return widget.breakfastFoods.isNotEmpty ||
        widget.lunchFoods.isNotEmpty ||
        widget.dinnerFoods.isNotEmpty;
  }

  Widget _buildMealCard(String mealName, String emoji, List<MenuModel> foods) {
    double mealCalories = getMealCalories(foods);

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${mealCalories.toStringAsFixed(0)} kcal',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
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
                          Text(
                            '${food.calories} kcal',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
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
    if (totalCalories <= recommendedLimit * 0.7) {
      return '✅ ยอดเยี่ยม! คุณควบคุมพลังงานได้ดีในวันนี้\n• รักษาระดับนี้ต่อไป\n• พักผ่อนให้เพียงพอ';
    } else if (totalCalories <= recommendedLimit) {
      return '⚠️ ปานกลาง ยังอยู่ในเกณฑ์ที่ยอมรับได้\n• หลีกเลี่ยงอาหารที่มีไขมันสูง\n• ออกกำลังกายเล็กน้อย';
    } else {
      return '🚨 พลังงานเกินที่แนะนำแล้ว\n• ลดมื้อเย็นหรือขนม\n• เพิ่มการเคลื่อนไหวระหว่างวัน\n• ดื่มน้ำมากขึ้น';
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
                    // Summary
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.lightGreen.shade100,
                            Colors.lightGreen.shade50,
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
                            Icons.today,
                            size: 40,
                            color: Color(0xFF1AA916),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'พลังงานรวมวันนี้',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          Text(
                            '${totalCalories.toStringAsFixed(0)} kcal',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(totalCalories),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'สถานะ: ${_getStatusText(totalCalories)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: _getStatusColor(totalCalories),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: (totalCalories / recommendedLimit).clamp(
                              0.0,
                              1.0,
                            ),
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getStatusColor(totalCalories),
                            ),
                            minHeight: 8,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${((totalCalories / recommendedLimit) * 100).toInt()}% ของพลังงานที่แนะนำ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
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
                                Icons.lightbulb_outline,
                                color: Colors.green.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'เคล็ดลับสำหรับวันนี้',
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
                  ],
                ),
              ),
    );
  }
}
