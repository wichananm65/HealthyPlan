import 'package:flutter/material.dart';
import 'package:healthy_plan/drawer.dart';
import 'package:healthy_plan/Page/summary.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthy Plan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF6AFF00)),
      ),
      home: MyHomePage(title: 'Healthy Plan'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key, required this.title});

  final String title;

  // Mock food data [food_name, calories_per_100g]
  final List<List<dynamic>> breakfastFoods = [
    ['ข้าวต้มหมู', 85],
    ['กล้วยหอม', 89],
    ['นมสด', 61],
  ];

  final List<List<dynamic>> lunchFoods = [
    ['ข้าวผัดกุ้ง', 163],
    ['ส้มตำ', 56],
    ['น้ำมะพร้าว', 19],
  ];

  final List<List<dynamic>> dinnerFoods = [
    ['แกงเขียวหวานไก่', 135],
    ['ข้าวสวย', 130],
    ['มะม่วงสุก', 60],
  ];

  Widget _buildFoodCards(List<List<dynamic>> foods) {
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
                      food[0],
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
                      '${food[1]} kcal',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      drawer: const MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 40), // Add some top spacing
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 3, color: Colors.lightGreen),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Table(
                border: TableBorder.symmetric(
                  inside: BorderSide(width: 3, color: Colors.lightGreen),
                ),
                columnWidths: const {
                  0: FlexColumnWidth(1), // มื้ออาหาร
                  1: FlexColumnWidth(3), // รายการอาหาร
                },
                children: [
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          '🍳 อาหารเช้า',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: _buildFoodCards(breakfastFoods),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          '🍛 อาหารกลางวัน',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: _buildFoodCards(lunchFoods),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          '🍲 อาหารเย็น',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: _buildFoodCards(dinnerFoods),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Space between table and button
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
                  // Pass today's food data to summary
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => TodaySummaryPage(
                            breakfastFoods: breakfastFoods,
                            lunchFoods: lunchFoods,
                            dinnerFoods: dinnerFoods,
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
            const Spacer(), // Push remaining content to bottom if needed
          ],
        ),
      ),
    );
  }
}
