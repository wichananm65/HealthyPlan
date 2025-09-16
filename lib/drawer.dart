import 'package:flutter/material.dart';
import 'package:healthy_plan/auth/auth_page.dart';
import 'package:healthy_plan/pages/bookmarks_page.dart';
import 'package:healthy_plan/pages/home_page.dart';
import 'package:healthy_plan/pages/menus_page.dart';
import 'package:healthy_plan/pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthy_plan/services/user_service.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.lightGreenAccent),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 50, color: Colors.grey),
                ),
                Stack(
                  children: [
                    Text(
                      '${UserService().getName()} ${UserService().getLastName()}',
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
                      '${UserService().getName()} ${UserService().getLastName()}',
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
            leading: const Icon(Icons.home),
            title: const Text('หน้าหลัก'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('โปรไฟล์'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyProfilePage(title: 'โปรไฟล์'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.food_bank_outlined),
            title: const Text('เมนู'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MenusPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text('รายการโปรด'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => const BookmarksPage(title: 'รายการโปรด'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'ออกจากระบบ',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              await UserService().clearCache();
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                // ignore: use_build_context_synchronously
                context,
                MaterialPageRoute(builder: (_) => AuthPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
