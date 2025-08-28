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
    }
  }

  Future<void> clearCache() async {
    await UserDB().clearUid();
    _uid = null;
    _firstName = null;
    _lastName = null;
    _age = null;
    _weight = null;
    _height = null;
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
    }
  }
}
