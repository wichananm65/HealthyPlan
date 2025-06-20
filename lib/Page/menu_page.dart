import 'package:flutter/material.dart';

void main() {
  runApp(const Menu());
}

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreenAccent),
      ),
      home: const MyMenuPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyMenuPage extends StatefulWidget {
  const MyMenuPage({super.key, required this.title});

  final String title;

  @override
  State<MyMenuPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyMenuPage> {
  String selectedPage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.lightGreenAccent),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: Colors.grey),
                  ),
                  Stack(
                    children: [
                      Text(
                        'ชื่อ - นามสกุล',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          foreground:
                              Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2
                                ..color = Colors.black,
                        ),
                      ),
                      Text(
                        'ชื่อ - นามสกุล',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('โปรไฟล์'),
              onTap: () {
                setState(() {
                  selectedPage = 'Profile';
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('เมนู'),
              onTap: () {
                setState(() {
                  selectedPage = 'Menu';
                });
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                setState(() {
                  selectedPage = 'Settings';
                });
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text('Page: $selectedPage')],
        ),
      ),
    );
  }
}
