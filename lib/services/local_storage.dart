import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  // Save user
  static Future<void> saveUser(String id, String name, String email, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', id);
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString('token', token);
  }

  // Get user
  static Future<Map<String, String>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString('id') ?? '',
      'name': prefs.getString('name') ?? '',
      'email': prefs.getString('email') ?? '',
      'token': prefs.getString('token') ?? '',
    };
  }

  // Clear user
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id');
    await prefs.remove('name');
    await prefs.remove('email');
    await prefs.remove('token');
  }
}
