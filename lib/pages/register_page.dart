import 'package:cloud_firestore/cloud_firestore.dart';
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
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String? _errorMessageEmail;
  String? _errorMessagePassword;
  String? _errorMessageConfirmPassword;
  String? _errorMessageFirstName;
  String? _errorMessageLastName;
  String? _errorMessageAge;
  String? _errorMessageWeight;
  String? _errorMessageHeight;
  String? _errorMessageGender;

  String? _selectedGender;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    bool valid = true;

    setState(() {
      _errorMessageEmail = null;
      _errorMessagePassword = null;
      _errorMessageConfirmPassword = null;
      _errorMessageFirstName = null;
      _errorMessageLastName = null;
      _errorMessageAge = null;
      _errorMessageWeight = null;
      _errorMessageHeight = null;
      _errorMessageGender = null;

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final age = _ageController.text.trim();
      final weight = _weightController.text.trim();
      final height = _heightController.text.trim();

      final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

      if (email.isEmpty) {
        _errorMessageEmail = 'กรุณากรอกอีเมล';
        valid = false;
      } else if (!emailRegex.hasMatch(email)) {
        _errorMessageEmail = 'รูปแบบอีเมลไม่ถูกต้อง';
        valid = false;
      }

      if (password.isEmpty) {
        _errorMessagePassword = 'กรุณากรอกรหัสผ่าน';
        valid = false;
      } else if (password.length < 6) {
        _errorMessagePassword = 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
        valid = false;
      }

      if (confirmPassword != password) {
        _errorMessageConfirmPassword = 'รหัสผ่านไม่ตรงกัน';
        valid = false;
      }

      if (firstName.isEmpty) {
        _errorMessageFirstName = 'กรุณากรอกชื่อ';
        valid = false;
      }

      if (lastName.isEmpty) {
        _errorMessageLastName = 'กรุณากรอกนามสกุล';
        valid = false;
      }

      if (age.isEmpty) {
        _errorMessageAge = 'กรุณากรอกอายุ';
        valid = false;
      } else if (int.tryParse(age) == null || int.parse(age) < 1) {
        _errorMessageAge = 'กรุณากรอกอายุให้ถูกต้อง';
        valid = false;
      }

      if (weight.isEmpty) {
        _errorMessageWeight = 'กรุณากรอกน้ำหนัก';
        valid = false;
      } else if (double.tryParse(weight) == null || double.parse(weight) < 1) {
        _errorMessageWeight = 'กรุณากรอกน้ำหนักให้ถูกต้อง';
        valid = false;
      }

      if (height.isEmpty) {
        _errorMessageHeight = 'กรุณากรอกส่วนสูง';
        valid = false;
      } else if (double.tryParse(height) == null || double.parse(height) < 1) {
        _errorMessageHeight = 'กรุณากรอกส่วนสูงให้ถูกต้อง';
        valid = false;
      }

      if (_selectedGender == null) {
        _errorMessageGender = 'กรุณาเลือกเพศ';
        valid = false;
      }
    });

    return valid;
  }

  Future signUp() async {
    if (!_validateFields()) return;

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = FirebaseAuth.instance.currentUser?.uid;
      await FirebaseAuth.instance.signOut();

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'first name': _firstNameController.text.trim(),
        'last name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'age': int.parse(_ageController.text.trim()),
        'weight': double.parse(_weightController.text.trim()),
        'height': double.parse(_heightController.text.trim()),
        'gender': _selectedGender,
        'favourite': null,
      });

      if (!mounted) return;
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? prefixIcon,
    bool obscureText = false,
    String? errorText,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelStyle: const TextStyle(color: Color(0xFF1AA916)),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF1AA916)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF1AA916)),
        ),
        errorText: errorText,
      ),
    );
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
                const SizedBox(height: 25),
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
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        prefixIcon: Icons.email,
                        errorText: _errorMessageEmail,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        prefixIcon: Icons.lock,
                        obscureText: true,
                        errorText: _errorMessagePassword,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        errorText: _errorMessageConfirmPassword,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _firstNameController,
                        label: 'ชื่อ',
                        prefixIcon: Icons.person,
                        errorText: _errorMessageFirstName,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _lastNameController,
                        label: 'นามสกุล',
                        prefixIcon: Icons.person_outline,
                        errorText: _errorMessageLastName,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _ageController,
                        label: 'อายุ',
                        keyboardType: TextInputType.number,
                        errorText: _errorMessageAge,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _weightController,
                        label: 'น้ำหนัก (kg)',
                        keyboardType: TextInputType.number,
                        errorText: _errorMessageWeight,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _heightController,
                        label: 'ส่วนสูง (cm)',
                        keyboardType: TextInputType.number,
                        errorText: _errorMessageHeight,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: _selectedGender,
                        decoration: InputDecoration(
                          labelText: 'เพศ',
                          floatingLabelStyle: const TextStyle(
                            color: Color(0xFF1AA916),
                          ),
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
                          errorText: _errorMessageGender,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'ชาย', child: Text('ชาย')),
                          DropdownMenuItem(value: 'หญิง', child: Text('หญิง')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
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
                        child: const Text(
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
