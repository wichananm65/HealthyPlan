import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_db.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  String? _uid;
  String? _firstName;
  String? _lastName;
  int? _age;
  double? _weight;
  double? _height;
  List<String> _favouriteMenus = [];
  List<String> _breakfast = [];
  List<String> _lunch = [];
  List<String> _dinner = [];

  List<String> get favouriteMenus => List.unmodifiable(_favouriteMenus);
  List<String> get breakfast => List.unmodifiable(_breakfast);
  List<String> get lunch => List.unmodifiable(_lunch);
  List<String> get dinner => List.unmodifiable(_dinner);

  Future<void> loadUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    _uid = await UserDB().getUid();

    if (_uid == null && currentUser != null) {
      _uid = currentUser.uid;
      await UserDB().saveUid(_uid!);
    }

    if (_uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(_uid).get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      _firstName = data['first name'] ?? '';
      _lastName = data['last name'] ?? '';
      _age = data['age'] ?? 0;
      _weight =
          (data['weight'] != null) ? (data['weight'] as num).toDouble() : 0;
      _height =
          (data['height'] != null) ? (data['height'] as num).toDouble() : 0;
      _favouriteMenus = List<String>.from(data['favourite'] ?? []);
      _breakfast = List<String>.from(data['breakfast'] ?? []);
      _lunch = List<String>.from(data['lunch'] ?? []);
      _dinner = List<String>.from(data['dinner'] ?? []);
    }
  }

  Future<void> addFavourite(String menuId) async {
    if (_uid == null) return;
    if (!_favouriteMenus.contains(menuId)) {
      _favouriteMenus.add(menuId);
      await FirebaseFirestore.instance.collection('users').doc(_uid).update({
        'favourite': _favouriteMenus,
      });
    }
  }

  Future<void> removeFavourite(String menuId) async {
    if (_uid == null) return;
    if (_favouriteMenus.contains(menuId)) {
      _favouriteMenus.remove(menuId);
      await FirebaseFirestore.instance.collection('users').doc(_uid).update({
        'favourite': _favouriteMenus,
      });
    }
  }

  Future<void> addToMeal(String mealType, String menuId) async {
    if (_uid == null) return;

    List<String> currentMeal;
    switch (mealType) {
      case 'breakfast':
        currentMeal = _breakfast;
        break;
      case 'lunch':
        currentMeal = _lunch;
        break;
      case 'dinner':
        currentMeal = _dinner;
        break;
      default:
        throw ArgumentError('Invalid meal type: $mealType');
    }

    // ลบการตรวจสอบการซ้ำกัน - อนุญาตให้เพิ่มได้ทุกครั้ง
    currentMeal.add(menuId);
    await FirebaseFirestore.instance.collection('users').doc(_uid).update({
      mealType: currentMeal,
    });
  }

  Future<void> removeFromMeal(String mealType, String menuId) async {
    if (_uid == null) return;

    List<String> currentMeal;
    switch (mealType) {
      case 'breakfast':
        currentMeal = _breakfast;
        break;
      case 'lunch':
        currentMeal = _lunch;
        break;
      case 'dinner':
        currentMeal = _dinner;
        break;
      default:
        throw ArgumentError('Invalid meal type: $mealType');
    }

    // ลบเฉพาะรายการแรกที่พบ (ในกรณีที่มีการซ้ำ)
    if (currentMeal.contains(menuId)) {
      currentMeal.remove(menuId);
      await FirebaseFirestore.instance.collection('users').doc(_uid).update({
        mealType: currentMeal,
      });
    }
  }

  Future<void> clearMeal(String mealType) async {
    if (_uid == null) return;

    List<String> currentMeal;
    switch (mealType) {
      case 'breakfast':
        currentMeal = _breakfast;
        break;
      case 'lunch':
        currentMeal = _lunch;
        break;
      case 'dinner':
        currentMeal = _dinner;
        break;
      default:
        throw ArgumentError('Invalid meal type: $mealType');
    }

    currentMeal.clear();
    await FirebaseFirestore.instance.collection('users').doc(_uid).update({
      mealType: currentMeal,
    });
  }

  Future<void> clearAllMeals() async {
    if (_uid == null) return;

    _breakfast.clear();
    _lunch.clear();
    _dinner.clear();

    await FirebaseFirestore.instance.collection('users').doc(_uid).update({
      'breakfast': _breakfast,
      'lunch': _lunch,
      'dinner': _dinner,
    });
  }

  Future<void> clearCache() async {
    await UserDB().clearUid();
    _uid = null;
    _firstName = null;
    _lastName = null;
    _age = null;
    _weight = null;
    _height = null;
    _favouriteMenus.clear();
    _breakfast.clear();
    _lunch.clear();
    _dinner.clear();
  }

  String getName() => _firstName ?? '';
  String getLastName() => _lastName ?? '';
  int getAge() => _age ?? 0;
  double getWeight() => _weight ?? 0;
  double getHeight() => _height ?? 0;

  Future<void> refresh() async {
    if (_uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(_uid).get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      _firstName = data['first name'] ?? '';
      _lastName = data['last name'] ?? '';
      _age = data['age'] ?? 0;
      _weight =
          (data['weight'] != null) ? (data['weight'] as num).toDouble() : 0;
      _height =
          (data['height'] != null) ? (data['height'] as num).toDouble() : 0;
      _favouriteMenus = List<String>.from(data['favourite'] ?? []);
      _breakfast = List<String>.from(data['breakfast'] ?? []);
      _lunch = List<String>.from(data['lunch'] ?? []);
      _dinner = List<String>.from(data['dinner'] ?? []);
    }
  }

  Future<void> updateUser({
    String? firstName,
    String? lastName,
    int? age,
    double? weight,
    double? height,
  }) async {
    if (_uid == null) return;

    final data = <String, dynamic>{};

    if (firstName != null) {
      _firstName = firstName;
      data['first name'] = firstName;
    }
    if (lastName != null) {
      _lastName = lastName;
      data['last name'] = lastName;
    }
    if (age != null) {
      _age = age;
      data['age'] = age;
    }
    if (weight != null) {
      _weight = weight;
      data['weight'] = weight;
    }
    if (height != null) {
      _height = height;
      data['height'] = height;
    }

    if (data.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .update(data);
    }
  }
}
