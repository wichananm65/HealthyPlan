import 'package:flutter/material.dart';
import 'package:healthy_plan/drawer.dart';

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
      home: const MyHomePage(title: 'Healthy Plan'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      drawer: const MyDrawer(),
      body: Align(
        alignment: Alignment(0, -0.4),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
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
              children: const [
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
                      child: Text(''), // ← ใส่รายการจาก database ภายหลัง
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
                    Padding(padding: EdgeInsets.all(12), child: Text('')),
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
                    Padding(padding: EdgeInsets.all(12), child: Text('')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
