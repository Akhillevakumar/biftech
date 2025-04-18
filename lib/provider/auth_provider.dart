import 'package:biftech/services/database_helper.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> initialize() async {
    await _dbHelper.init();
  }

  Future<bool> login(String email, String password) async {
    if (!_validateEmail(email) || !_validatePassword(password)) return false;

    final user = await _dbHelper.getUser(email);
    if (user != null && user['password'] == password) {
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String email, String password) async {
    if (!_validateEmail(email) || !_validatePassword(password)) return false;

    final existingUser = await _dbHelper.getUser(email);
    if (existingUser == null) {
      await _dbHelper.insertUser(email, password);
      return true;
    }
    return false;
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  bool _validateEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  bool _validatePassword(String password) {
    return RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$').hasMatch(password);
  }
}