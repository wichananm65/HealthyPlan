import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthy_plan/auth/auth_page.dart';
import 'package:healthy_plan/pages/home_page.dart';
import 'package:healthy_plan/services/user_service.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // โหลดข้อมูลผู้ใช้เมื่อมีการล็อกอิน
            return FutureBuilder(
              future: UserService().loadUser(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  // แสดง loading ระหว่างโหลดข้อมูล
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    ),
                  );
                }
                return const HomePage();
              },
            );
          } else {
            return const AuthPage();
          }
        },
      ),
    );
  }
}
