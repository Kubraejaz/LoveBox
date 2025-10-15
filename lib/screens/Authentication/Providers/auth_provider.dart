import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lovebox/screens/Core/local_storage.dart';
import '../../../constants/api_endpoints.dart';
import '../../Profile/Models/user_model.dart';


class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Register
  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['user'] != null) {
          _user = UserModel.fromJson(data['user']);
          // ✅ Save full UserModel
          await LocalStorage.saveUser(_user!);
        }
        _errorMessage = null;
        _setLoading(false);
        return true;
      } else {
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          _errorMessage = errors.values.first[0];
        } else if (data['message'] != null) {
          _errorMessage = data['message'];
        } else {
          _errorMessage = "Registration failed";
        }
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = "Something went wrong: $e";
      _setLoading(false);
      return false;
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['user'] != null) {
        _user = UserModel.fromJson(data['user']);
        // ✅ Save full UserModel
        await LocalStorage.saveUser(_user!);
        _errorMessage = null;
        _setLoading(false);
        return true;
      } else {
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          _errorMessage = errors.values.first[0];
        } else if (data['message'] != null) {
          _errorMessage = data['message'];
        } else {
          _errorMessage = "Invalid email or password";
        }
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = "Something went wrong: $e";
      _setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _user = null;
    await LocalStorage.clearUser();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Load user from local storage
  Future<void> loadUserFromLocal() async {
    final user = await LocalStorage.getUser(); // ✅ directly returns UserModel?
    if (user != null) {
      _user = user;
      notifyListeners();
    }
  }
}
