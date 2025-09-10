import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class LocalStorage {
  // ------------------- USER -------------------
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    // ✅ ek hi key 'user' me full JSON save hoga
    await prefs.setString('user', jsonEncode(user.toJson()));
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('user');
    if (data == null || data.isEmpty) return null;

    try {
      final Map<String, dynamic> json = jsonDecode(data);
      return UserModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user'); // ✅ clear full user
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
