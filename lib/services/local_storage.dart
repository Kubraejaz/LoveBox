import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class LocalStorage {
  // ------------------- KEYS -------------------
  static const _userKey = 'user';
  static const _authTokenKey = 'authToken';
  static const _navIndexKey = 'navIndex';

  // ------------------- USER -------------------
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userKey);
    if (data == null || data.isEmpty) return null;

    try {
      final jsonMap = jsonDecode(data) as Map<String, dynamic>;
      return UserModel.fromJson(jsonMap);
    } catch (e) {
      // Corrupted or outdated data—clear it to avoid loops.
      await prefs.remove(_userKey);
      return null;
    }
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // ------------------- AUTH TOKEN -------------------
  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  static Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
  }

  // ------------------- NAVBAR INDEX -------------------
  static Future<void> saveNavIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_navIndexKey, index);
  }

  static Future<int> getNavIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_navIndexKey) ?? 0;
  }

  static Future<void> resetNavIndex() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_navIndexKey, 0);
  }

  // ------------------- CART (Per User) -------------------
  static Future<void> saveCart(
    String userId,
    List<Map<String, dynamic>> cart,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cart_$userId', jsonEncode(cart));
  }

  static Future<List<Map<String, dynamic>>> getCart(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('cart_$userId');
    if (data == null || data.isEmpty) return [];
    try {
      final List decoded = jsonDecode(data);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      // If decoding fails, clear corrupted cart and return empty.
      await prefs.remove('cart_$userId');
      return [];
    }
  }

  static Future<void> clearCart(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart_$userId');
  }

  // ------------------- GENERIC STORAGE -------------------
  static Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> removeKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // ------------------- CHECK LOGIN STATE -------------------
  static Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // ------------------- CLEAR ALL USER DATA -------------------
  static Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_authTokenKey);
    // Optionally clear navIndex or carts if needed.
  }
}
