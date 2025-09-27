import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Handles all local persistence: user info, auth token, navbar index,
/// and per–user cart data.
class LocalStorage {
  // ------------------- KEYS -------------------
  static const String _userKey = 'user';
  static const String _authTokenKey = 'authToken';
  static const String _navIndexKey = 'navIndex';

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
      // If JSON is corrupted or from an older version, clear it.
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
      // Corrupted cart data—clear and return empty list
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
  /// Returns true if an auth token exists and is not empty.
  static Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // ------------------- CLEAR ALL USER DATA -------------------
  /// Clears user profile and token.
  /// If you also want to reset nav index or cart, call those methods separately.
  static Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_authTokenKey);
    // Optionally: await resetNavIndex();
    // Optionally: clearCart for each user if required.
  }
}
