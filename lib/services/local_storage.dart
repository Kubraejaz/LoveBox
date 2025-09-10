import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorage {
  // ------------------- USER -------------------
  static Future<void> saveUser(
    String id,
    String name,
    String email,
    String token,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', id);
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString('token', token);
  }

  static Future<Map<String, String>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString('id') ?? '',
      'name': prefs.getString('name') ?? '',
      'email': prefs.getString('email') ?? '',
      'token': prefs.getString('token') ?? '',
    };
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id');
    await prefs.remove('name');
    await prefs.remove('email');
    await prefs.remove('token');
    await prefs.remove('navIndex');
  }

  // ------------------- NAVBAR INDEX -------------------
  static Future<void> saveNavIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('navIndex', index);
  }

  static Future<int> getNavIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('navIndex') ?? 0;
  }

  // ✅ Added: Reset nav index to 0 (for fresh login)
  static Future<void> resetNavIndex() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('navIndex', 0);
  }

  // ------------------- CART (Per User) -------------------
  static Future<void> saveCart(
    String userId,
    List<Map<String, dynamic>> cart,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    String key = "cart_$userId";
    await prefs.setString(key, jsonEncode(cart));
  }

  static Future<List<Map<String, dynamic>>> getCart(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    String key = "cart_$userId";
    String? data = prefs.getString(key);

    if (data == null) return [];
    List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> clearCart(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    String key = "cart_$userId";
    await prefs.remove(key);
  }
}
