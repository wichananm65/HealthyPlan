import 'package:flutter/material.dart';
import 'package:healthy_plan/drawer.dart';
import 'package:healthy_plan/services/user_service.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key, required this.title});

  final String title;

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    await UserService().loadUser();
    if (!mounted) return;
    setState(() {
      _nameController.text = UserService().getName();
      _surNameController.text = UserService().getLastName();
      _ageController.text = UserService().getAge().toString();
      _weightController.text = UserService().getWeight().toString();
      _heightController.text = UserService().getHeight().toString();
      _selectedGender = UserService().getGender(); // ดึงค่าเดิม
    });
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final surName = _surNameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final gender =
        _selectedGender ?? UserService().getGender(); // ถ้าไม่แก้ ใช้ค่าเดิม

    await UserService().updateUser(
      firstName: name,
      lastName: surName,
      age: age,
      weight: weight,
      height: height,
      gender: gender,
    );

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
              'อัปเดทข้อมูลเรียบร้อย',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
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
  }

  TextFormField _buildTextField(
    TextEditingController controller,
    String label,
    bool isNumber,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType:
          isNumber ? TextInputType.numberWithOptions(decimal: true) : null,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelStyle: const TextStyle(color: Color(0xFF1AA916)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF1AA916)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF1AA916)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'กรุณากรอก $label';
        }
        if (isNumber) {
          final number = double.tryParse(value);
          if (number == null) return 'กรุณากรอกตัวเลขที่ถูกต้อง';
          if (number < 1) return '$label ต้องมากกว่า 0';
        }
        return null;
      },
    );
  }

  Widget _buildGenderField() {
    return DropdownButtonFormField<String>(
      // ignore: deprecated_member_use
      value: _selectedGender ?? UserService().getGender(),
      decoration: InputDecoration(
        labelText: 'เพศ',
        floatingLabelStyle: const TextStyle(color: Color(0xFF1AA916)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF1AA916)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF1AA916)),
        ),
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
      validator: (value) {
        if (value == null || value.isEmpty) return 'กรุณาเลือกเพศ';
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(widget.title),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      drawer: MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                _buildTextField(_nameController, 'ชื่อ', false),
                const SizedBox(height: 16),
                _buildTextField(_surNameController, 'นามสกุล', false),
                const SizedBox(height: 16),
                _buildTextField(_ageController, 'อายุ', true),
                const SizedBox(height: 16),
                _buildGenderField(),
                const SizedBox(height: 16),
                _buildTextField(_weightController, 'น้ำหนัก', true),
                const SizedBox(height: 16),
                _buildTextField(_heightController, 'ส่วนสูง', true),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'บันทึก',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
