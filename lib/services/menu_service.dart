import 'package:cloud_firestore/cloud_firestore.dart';

class MenuModel {
  final String id;
  final String benefit;
  final int calories;
  final double sugarContent;
  final String foodName;
  final String howTo;
  final String ingredient;
  final String? picture;
  final String type;

  MenuModel({
    required this.id,
    required this.benefit,
    required this.calories,
    required this.sugarContent,
    required this.foodName,
    required this.howTo,
    required this.ingredient,
    required this.type,
    this.picture,
  });

  factory MenuModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    String convertToString(dynamic value) {
      if (value == null) return '';
      if (value is List) {
        if (value.isEmpty) return '';
        List<String> lines = [];
        for (int i = 0; i < value.length; i++) {
          lines.add('${i + 1}. ${value[i]}');
        }
        return lines.join('\n');
      }
      if (value is String) return value;
      return value.toString();
    }

    int convertToInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.round();
      if (value is num) return value.round();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    double convertToDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return MenuModel(
      id: doc.id,
      benefit: data['benefit']?.toString() ?? '',
      calories: convertToInt(data['calories']),
      sugarContent: convertToDouble(data['sugarContent']),
      foodName: data['foodName']?.toString() ?? '',
      howTo: convertToString(data['howTo']),
      ingredient: convertToString(data['ingredient']),
      type: data['type']?.toString() ?? 'อาหาร',
      picture: data['picture']?.toString(),
    );
  }
}

class MenuService {
  static final MenuService _instance = MenuService._internal();
  factory MenuService() => _instance;
  MenuService._internal();

  final CollectionReference _menuCollection = FirebaseFirestore.instance
      .collection('menu');

  List<MenuModel> _allMenus = [];
  bool _isLoaded = false;

  Future<List<MenuModel>> loadAllMenus({bool forceRefresh = false}) async {
    if (_isLoaded && !forceRefresh) {
      return _allMenus;
    }

    try {
      QuerySnapshot querySnapshot =
          await _menuCollection.orderBy('foodName').get();

      _allMenus =
          querySnapshot.docs
              .map((doc) => MenuModel.fromFirestore(doc))
              .toList();

      _isLoaded = true;
      return _allMenus;
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการโหลดข้อมูลเมนู: $e');
    }
  }

  List<MenuModel> searchMenusByName(String query) {
    if (query.isEmpty) return _allMenus;

    String searchQuery = query.toLowerCase().trim();
    return _allMenus.where((menu) {
      return menu.foodName.toLowerCase().contains(searchQuery);
    }).toList();
  }

  List<MenuModel> searchMenusByIngredient(String query) {
    if (query.isEmpty) return _allMenus;

    String searchQuery = query.toLowerCase().trim();
    return _allMenus.where((menu) {
      return menu.ingredient.toLowerCase().contains(searchQuery);
    }).toList();
  }

  List<MenuModel> searchMenusByBenefit(String query) {
    if (query.isEmpty) return _allMenus;

    String searchQuery = query.toLowerCase().trim();
    return _allMenus.where((menu) {
      return menu.benefit.toLowerCase().contains(searchQuery);
    }).toList();
  }

  List<MenuModel> searchMenusAll(String query) {
    if (query.isEmpty) return _allMenus;

    String searchQuery = query.toLowerCase().trim();
    return _allMenus.where((menu) {
      return menu.foodName.toLowerCase().contains(searchQuery) ||
          menu.ingredient.toLowerCase().contains(searchQuery) ||
          menu.benefit.toLowerCase().contains(searchQuery);
    }).toList();
  }

  List<MenuModel> filterMenusByCalories({int? minCalories, int? maxCalories}) {
    return _allMenus.where((menu) {
      bool matchMin = minCalories == null || menu.calories >= minCalories;
      bool matchMax = maxCalories == null || menu.calories <= maxCalories;
      return matchMin && matchMax;
    }).toList();
  }

  List<MenuModel> filterMenusBySugar({double? minSugar, double? maxSugar}) {
    return _allMenus.where((menu) {
      bool matchMin = minSugar == null || menu.sugarContent >= minSugar;
      bool matchMax = maxSugar == null || menu.sugarContent <= maxSugar;
      return matchMin && matchMax;
    }).toList();
  }

  MenuModel? getMenuById(String id) {
    try {
      return _allMenus.firstWhere((menu) => menu.id == id);
    } catch (e) {
      return null;
    }
  }

  // Updated addMenu method to handle both List<String> and String for ingredients/howTo
  Future<String> addMenu({
    required String foodName,
    required String benefit,
    required int calories,
    required double sugarContent,
    required dynamic howTo, // Can be List<String> or String
    required dynamic ingredients, // Can be List<String> or String
    String? picture,
    required String type,
  }) async {
    try {
      // Convert howTo to appropriate format
      dynamic howToData;
      if (howTo is List<String>) {
        howToData = howTo;
      } else if (howTo is String) {
        // Split by newlines if it's a string with numbered steps
        howToData =
            howTo.split('\n').where((step) => step.trim().isNotEmpty).toList();
      } else {
        howToData = howTo.toString();
      }

      // Convert ingredients to appropriate format
      dynamic ingredientData;
      if (ingredients is List<String>) {
        ingredientData = ingredients;
      } else if (ingredients is String) {
        // Split by newlines if it's a string with numbered ingredients
        ingredientData =
            ingredients
                .split('\n')
                .where((ingredient) => ingredient.trim().isNotEmpty)
                .toList();
      } else {
        ingredientData = ingredients.toString();
      }

      DocumentReference docRef = await _menuCollection.add({
        'foodName': foodName,
        'benefit': benefit,
        'calories': calories,
        'sugarContent': sugarContent,
        'howTo': howToData,
        'ingredient': ingredientData,
        'picture': picture,
        'type': type,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Refresh the cache after adding
      await loadAllMenus(forceRefresh: true);

      return docRef.id;
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการเพิ่มเมนู: $e');
    }
  }

  Future<void> updateMenu(String menuId, Map<String, dynamic> data) async {
    try {
      await _menuCollection.doc(menuId).update(data);
      await loadAllMenus(forceRefresh: true);
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการอัปเดตเมนู: $e');
    }
  }

  Future<void> deleteMenu(String menuId) async {
    try {
      await _menuCollection.doc(menuId).delete();
      await loadAllMenus(forceRefresh: true);
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการลบเมนู: $e');
    }
  }

  void clearCache() {
    _allMenus.clear();
    _isLoaded = false;
  }

  bool get isLoaded => _isLoaded;
  int get totalMenuCount => _allMenus.length;
  List<MenuModel> get allMenus => List.unmodifiable(_allMenus);
}
