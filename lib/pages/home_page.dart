import 'package:flutter/material.dart';
import 'package:healthy_plan/pages/summary.dart';
import 'package:healthy_plan/drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  final List<List<dynamic>> breakfastFoods = const [
    ['ข้าวต้มหมู', 85],
    ['กล้วยหอม', 89],
    ['นมสด', 61],
  ];

  final List<List<dynamic>> lunchFoods = const [
    ['ข้าวผัดกุ้ง', 163],
    ['ส้มตำ', 56],
    ['น้ำมะพร้าว', 19],
  ];

  final List<List<dynamic>> dinnerFoods = const [
    ['แกงเขียวหวานไก่', 135],
    ['ข้าวสวย', 130],
    ['มะม่วงสุก', 60],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Healthy Plan'),
        backgroundColor: Colors.green,
      ),
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            FoodTable(
              breakfastFoods: breakfastFoods,
              lunchFoods: lunchFoods,
              dinnerFoods: dinnerFoods,
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

  final List<List<dynamic>> breakfastFoods;
  final List<List<dynamic>> lunchFoods;
  final List<List<dynamic>> dinnerFoods;

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
                child: FoodCardList(foods: dinnerFoods),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget สำหรับ Card แสดงอาหาร
class FoodCardList extends StatelessWidget {
  const FoodCardList({super.key, required this.foods});

  final List<List<dynamic>> foods;

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
}
