import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../models/user_model.dart';
import '../services/local_storage.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Register
  Future<void> register(String name, String email, String password) async {
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['user'] != null) {
          _user = UserModel.fromJson(data['user']);
          await LocalStorage.saveUser(
            _user!.id,
            _user!.name,
            _user!.email,
            _user!.token,
          );
        }
        _errorMessage = null;
      } else {
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          _errorMessage = errors.values.first[0];
        } else if (data['message'] != null) {
          _errorMessage = data['message'];
        } else {
          _errorMessage = "Registration failed";
        }
      }
    } catch (e) {
      _errorMessage = "Something went wrong: $e";
    }
    _setLoading(false);
  }

  // Login
  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['user'] != null) {
        _user = UserModel.fromJson(data['user']);
        await LocalStorage.saveUser(
          _user!.id,
          _user!.name,
          _user!.email,
          _user!.token,
        );
        _errorMessage = null;
      } else {
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          _errorMessage = errors.values.first[0];
        } else if (data['message'] != null) {
          _errorMessage = data['message'];
        } else {
          _errorMessage = "Invalid email or password";
        }
      }
    } catch (e) {
      _errorMessage = "Something went wrong: $e";
    }
    _setLoading(false);
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

  Future<void> loadUserFromLocal() async {
    final userMap = await LocalStorage.getUser();
    if (userMap['id'] != null &&
        userMap['name'] != null &&
        userMap['email'] != null &&
        userMap['token'] != null) {
      _user = UserModel(
        id: userMap['id']!,
        name: userMap['name']!,
        email: userMap['email']!,
        token: userMap['token']!,
      );
      notifyListeners();
    }
  }
}
