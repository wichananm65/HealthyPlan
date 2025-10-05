import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:healthy_plan/services/menu_service.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

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
  List<TextEditingController> _ingredientControllers = [
    TextEditingController(),
  ];
  List<TextEditingController> _howToControllers = [TextEditingController()];
  bool _isLoading = false;

  File? _selectedImageFile;
  Uint8List? _webImageBytes;
  String? _imageFileName;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _foodNameController.dispose();
    _benefitController.dispose();
    _caloriesController.dispose();
    _sugarController.dispose();
    for (var c in _ingredientControllers) c.dispose();
    for (var c in _howToControllers) c.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );
      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
            _imageFileName = image.name;
            _selectedImageFile = null;
          });
        } else {
          setState(() {
            _selectedImageFile = File(image.path);
            _imageFileName = image.name;
            _webImageBytes = null;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการเลือกรูป: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImageFile == null && _webImageBytes == null) return null;

    try {
      final cloudinary = CloudinaryPublic(
        'dkxhgge2v', // ✅ แทนด้วยของคุณ
        'healthy_plan_upload', // ✅ แทนด้วยของคุณ
        cache: false,
      );

      CloudinaryResponse response;

      if (kIsWeb && _webImageBytes != null) {
        // ✅ สำหรับเว็บ
        response = await cloudinary.uploadFile(
          CloudinaryFile.fromBytesData(
            _webImageBytes!,
            identifier: 'menu_image', // ← เพิ่มบรรทัดนี้
            resourceType: CloudinaryResourceType.Image,
            folder: 'menu_images',
          ),
        );
      } else if (_selectedImageFile != null) {
        // ✅ สำหรับมือถือ
        response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            _selectedImageFile!.path,
            identifier: 'menu_image', // ← เพิ่มบรรทัดนี้
            folder: 'menu_images',
            resourceType: CloudinaryResourceType.Image,
          ),
        );
      } else {
        return null;
      }

      return response.secureUrl; // ✅ URL รูปที่จะเก็บใน Firebase
    } catch (e) {
      throw Exception('อัปโหลดรูปไม่สำเร็จ: ${e.toString()}');
    }
  }

  void _addIngredientField() =>
      setState(() => _ingredientControllers.add(TextEditingController()));

  void _removeIngredientField(int index) {
    if (_ingredientControllers.length > 1) {
      _ingredientControllers[index].dispose();
      setState(() => _ingredientControllers.removeAt(index));
    }
  }

  void _addHowToField() =>
      setState(() => _howToControllers.add(TextEditingController()));

  void _removeHowToField(int index) {
    if (_howToControllers.length > 1) {
      _howToControllers[index].dispose();
      setState(() => _howToControllers.removeAt(index));
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final imageUrl = await _uploadImage(); // คืนค่า null ได้
      final ingredients =
          _ingredientControllers
              .map((c) => c.text.trim())
              .where((s) => s.isNotEmpty)
              .toList();
      final howTo =
          _howToControllers
              .map((c) => c.text.trim())
              .where((s) => s.isNotEmpty)
              .toList();

      final menuService = MenuService();
      await menuService.addMenu(
        foodName: _foodNameController.text.trim(),
        benefit: _benefitController.text.trim(),
        calories: int.parse(_caloriesController.text.trim()),
        sugarContent: double.parse(_sugarController.text.trim()),
        ingredients: ingredients,
        howTo: howTo,
        picture: imageUrl, // สามารถเป็น null ได้
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
    for (var c in _ingredientControllers) c.dispose();
    for (var c in _howToControllers) c.dispose();
    setState(() {
      _ingredientControllers = [TextEditingController()];
      _howToControllers = [TextEditingController()];
      _selectedImageFile = null;
      _webImageBytes = null;
      _imageFileName = null;
    });
  }

  // --- UI เหมือนเดิม ---
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
                      validator:
                          (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'กรุณากรอกชื่อเมนู'
                                  : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _benefitController,
                      label: 'ประโยชน์',
                      hint: 'เช่น ช่วยเสริมสร้างภูมิคุ้มกัน',
                      maxLines: 3,
                      validator:
                          (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'กรุณากรอกประโยชน์'
                                  : null,
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
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'กรุณากรอกแคลลอรี่';
                              if (int.tryParse(v.trim()) == null)
                                return 'กรุณากรอกตัวเลข';
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
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'กรุณากรอกระดับน้ำตาล';
                              if (double.tryParse(v.trim()) == null)
                                return 'กรุณากรอกตัวเลข';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildImagePicker(),
                  ],
                ),
                const SizedBox(height: 20),
                // --- ส่วนผสม และ วิธีทำ ---
                _buildIngredientCard(),
                const SizedBox(height: 20),
                _buildHowToCard(),
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

  Widget _buildIngredientCard() {
    return _buildCard(
      title: 'ส่วนผสม',
      icon: Icons.list,
      children: [
        ..._ingredientControllers.asMap().entries.map((entry) {
          int index = entry.key;
          TextEditingController c = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: c,
                    label: 'ส่วนผสมที่ ${index + 1}',
                    hint: 'เช่น มะเขือเทศ 2 ลูก',
                    validator:
                        index == 0
                            ? (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'กรุณากรอกส่วนผสมอย่างน้อย 1 รายการ'
                                    : null
                            : null,
                  ),
                ),
                if (_ingredientControllers.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _removeIngredientField(index),
                  ),
              ],
            ),
          );
        }).toList(),
        TextButton.icon(
          onPressed: _addIngredientField,
          icon: const Icon(Icons.add),
          label: const Text('เพิ่มส่วนผสม'),
          style: TextButton.styleFrom(foregroundColor: Colors.green),
        ),
      ],
    );
  }

  Widget _buildHowToCard() {
    return _buildCard(
      title: 'วิธีทำ',
      icon: Icons.receipt,
      children: [
        ..._howToControllers.asMap().entries.map((entry) {
          int index = entry.key;
          TextEditingController c = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: c,
                    label: 'ขั้นตอนที่ ${index + 1}',
                    hint: 'เช่น นำมะเขือเทศมาหั่น',
                    maxLines: 2,
                    validator:
                        index == 0
                            ? (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'กรุณากรอกวิธีทำอย่างน้อย 1 ขั้นตอน'
                                    : null
                            : null,
                  ),
                ),
                if (_howToControllers.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _removeHowToField(index),
                  ),
              ],
            ),
          );
        }).toList(),
        TextButton.icon(
          onPressed: _addHowToField,
          icon: const Icon(Icons.add),
          label: const Text('เพิ่มขั้นตอน'),
          style: TextButton.styleFrom(foregroundColor: Colors.green),
        ),
      ],
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
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.image, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Text(
              'รูปภาพเมนู',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child:
                _selectedImageFile != null || _webImageBytes != null
                    ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child:
                              kIsWeb && _webImageBytes != null
                                  ? Image.memory(
                                    _webImageBytes!,
                                    fit: BoxFit.cover,
                                  )
                                  : _selectedImageFile != null
                                  ? Image.file(
                                    _selectedImageFile!,
                                    fit: BoxFit.cover,
                                  )
                                  : Container(),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedImageFile = null;
                                  _webImageBytes = null;
                                  _imageFileName = null;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'แตะเพื่อเลือกรูปภาพ',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '(ไม่บังคับ)',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
        if (_imageFileName != null) ...[
          const SizedBox(height: 8),
          Text(
            'ไฟล์: $_imageFileName',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ],
    );
  }
}
