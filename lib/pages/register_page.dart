import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;

  const RegisterPage({super.key, required this.showLoginPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _errorMessageEmail;
  String? _errorMessagePassword;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future signUp() async {
    setState(() {
      _errorMessageEmail = null;
      _errorMessagePassword = null;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // logout ทันที เพื่อไม่ให้ auto-login
      await FirebaseAuth.instance.signOut();

      if (!mounted) return; // ตรวจสอบก่อน show dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: const Text(
                'สมัครสมาชิกสำเร็จ!\nโปรดกลับไปหน้า Login เพื่อเข้าสู่ระบบ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              actions: [
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.showLoginPage();
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Color(0xFF1AA916), fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.code == 'email-already-in-use') {
          _errorMessageEmail = 'อีเมลนี้มีบัญชีอยู่แล้ว';
        } else if (e.code == 'invalid-email') {
          _errorMessageEmail = 'อีเมลไม่ถูกต้อง';
        } else if (e.code == 'weak-password') {
          _errorMessagePassword = 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
        } else {
          _errorMessagePassword = 'เกิดข้อผิดพลาด';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 300),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'สมัครสมาชิก Healthy Plan!!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1AA916),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          floatingLabelStyle: const TextStyle(
                            color: Color(0xFF1AA916),
                          ),
                          prefixIcon: const Icon(Icons.email),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Color(0xFF1AA916),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Color(0xFF1AA916),
                            ),
                          ),
                          errorText: _errorMessageEmail,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          floatingLabelStyle: const TextStyle(
                            color: Color(0xFF1AA916),
                          ),
                          prefixIcon: const Icon(Icons.lock),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Color(0xFF1AA916),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Color(0xFF1AA916),
                            ),
                          ),
                          errorText: _errorMessagePassword,
                        ),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: signUp,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: const Color(0xFF1AA916)),
                          ),
                          child: const Text(
                            'สมัครสมาชิก',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF1AA916),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: widget.showLoginPage,
                        child: Text(
                          'มีบัญชีอยู่แล้ว',
                          style: TextStyle(color: Colors.purple),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
