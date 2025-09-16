import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:healthy_plan/services/menu_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Panel - Healthy Plan',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'TH Sarabun New',
      ),
      home: const AdminHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel - Healthy Plan'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.withOpacity(0.1), Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 80,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'ยินดีต้อนรับ Admin',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'จัดการข้อมูลเมนูอาหาร',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
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
                              builder: (context) => const AdminAddMenuPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.restaurant_menu, size: 24),
                        label: const Text(
                          'เพิ่มเมนูใหม่',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// admin_add_menu_page.dart
class AdminAddMenuPage extends StatefulWidget {
  const AdminAddMenuPage({super.key});

  @override
  State<AdminAddMenuPage> createState() => _AdminAddMenuPageState();
}

class _AdminAddMenuPageState extends State<AdminAddMenuPage> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  final _benefitController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _sugarController = TextEditingController();
  final _pictureController = TextEditingController();

  List<TextEditingController> _ingredientControllers = [
    TextEditingController(),
  ];
  List<TextEditingController> _howToControllers = [TextEditingController()];

  bool _isLoading = false;

  @override
  void dispose() {
    _foodNameController.dispose();
    _benefitController.dispose();
    _caloriesController.dispose();
    _sugarController.dispose();
    _pictureController.dispose();
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    for (var controller in _howToControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredientField(int index) {
    if (_ingredientControllers.length > 1) {
      setState(() {
        _ingredientControllers[index].dispose();
        _ingredientControllers.removeAt(index);
      });
    }
  }

  void _addHowToField() {
    setState(() {
      _howToControllers.add(TextEditingController());
    });
  }

  void _removeHowToField(int index) {
    if (_howToControllers.length > 1) {
      setState(() {
        _howToControllers[index].dispose();
        _howToControllers.removeAt(index);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Get ingredients and howTo as lists
      List<String> ingredients =
          _ingredientControllers
              .map((controller) => controller.text.trim())
              .where((text) => text.isNotEmpty)
              .toList();

      List<String> howToSteps =
          _howToControllers
              .map((controller) => controller.text.trim())
              .where((text) => text.isNotEmpty)
              .toList();

      // Add to Firebase using MenuService
      final menuService = MenuService();
      await menuService.addMenu(
        foodName: _foodNameController.text.trim(),
        benefit: _benefitController.text.trim(),
        calories: int.parse(_caloriesController.text.trim()),
        sugarContent: double.parse(_sugarController.text.trim()),
        howTo: howToSteps,
        ingredients: ingredients,
        picture:
            _pictureController.text.trim().isNotEmpty
                ? _pictureController.text.trim()
                : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เพิ่มเมนูใหม่เรียบร้อยแล้ว'),
            backgroundColor: Colors.green,
          ),
        );
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _foodNameController.clear();
    _benefitController.clear();
    _caloriesController.clear();
    _sugarController.clear();
    _pictureController.clear();

    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    for (var controller in _howToControllers) {
      controller.dispose();
    }

    setState(() {
      _ingredientControllers = [TextEditingController()];
      _howToControllers = [TextEditingController()];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มเมนูใหม่'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.withOpacity(0.1), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCard(
                  title: 'ข้อมูลพื้นฐาน',
                  icon: Icons.info,
                  children: [
                    _buildTextField(
                      controller: _foodNameController,
                      label: 'ชื่อเมนู',
                      hint: 'เช่น ส้มตำไทย',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณากรอกชื่อเมนู';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _benefitController,
                      label: 'ประโยชน์',
                      hint: 'เช่น ช่วยเสริมสร้างภูมิคุ้มกัน',
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณากรอกประโยชน์';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _caloriesController,
                            label: 'แคลลอรี่ (kcal)',
                            hint: '150',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'กรุณากรอกแคลลอรี่';
                              }
                              if (int.tryParse(value.trim()) == null) {
                                return 'กรุณากรอกตัวเลข';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _sugarController,
                            label: 'ระดับน้ำตาล (g)',
                            hint: '5.5',
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'กรุณากรอกระดับน้ำตาล';
                              }
                              if (double.tryParse(value.trim()) == null) {
                                return 'กรุณากรอกตัวเลข';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _pictureController,
                      label: 'URL รูปภาพ (ไม่บังคับ)',
                      hint: 'https://example.com/image.jpg',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildCard(
                  title: 'ส่วนผสม',
                  icon: Icons.list,
                  children: [
                    ..._ingredientControllers.asMap().entries.map((entry) {
                      int index = entry.key;
                      TextEditingController controller = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: controller,
                                label: 'ส่วนผสมที่ ${index + 1}',
                                hint: 'เช่น มะเขือเทศสุก 2 ลูก',
                                validator:
                                    index == 0
                                        ? (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'กรุณากรอกส่วนผสมอย่างน้อย 1 รายการ';
                                          }
                                          return null;
                                        }
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_ingredientControllers.length > 1)
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeIngredientField(index),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _addIngredientField,
                      icon: const Icon(Icons.add),
                      label: const Text('เพิ่มส่วนผสม'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildCard(
                  title: 'วิธีทำ',
                  icon: Icons.receipt,
                  children: [
                    ..._howToControllers.asMap().entries.map((entry) {
                      int index = entry.key;
                      TextEditingController controller = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: controller,
                                label: 'ขั้นตอนที่ ${index + 1}',
                                hint: 'เช่น นำมะเขือเทศมาหั่นเป็นชิ้นเล็กๆ',
                                maxLines: 2,
                                validator:
                                    index == 0
                                        ? (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'กรุณากรอกวิธีทำอย่างน้อย 1 ขั้นตอน';
                                          }
                                          return null;
                                        }
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_howToControllers.length > 1)
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeHowToField(index),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _addHowToField,
                      icon: const Icon(Icons.add),
                      label: const Text('เพิ่มขั้นตอน'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 3,
                    ),
                    onPressed: _isLoading ? null : _submitForm,
                    icon:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Icon(Icons.save, size: 24),
                    label: Text(
                      _isLoading ? 'กำลังบันทึก...' : 'บันทึกเมนู',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: _isLoading ? null : _resetForm,
                  icon: const Icon(Icons.refresh),
                  label: const Text('รีเซ็ตฟอร์ม'),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.green),
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
