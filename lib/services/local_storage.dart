import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _idKey = 'user_id';
  static const _nameKey = 'user_name';
  static const _emailKey = 'user_email';
  static const _tokenKey = 'user_token';
  static const _firstTimeKey = 'first_time';

  static Future<void> saveUser(String id, String name, String email, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_idKey, id);
    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_tokenKey, token);
    await prefs.setBool(_firstTimeKey, false);
  }

  static Future<Map<String, String?>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "id": prefs.getString(_idKey),
      "name": prefs.getString(_nameKey),
      "email": prefs.getString(_emailKey),
      "token": prefs.getString(_tokenKey),
    };
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_idKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_tokenKey);
  }

  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstTimeKey) ?? true;
  }

  static Future<void> setFirstTimeFalse() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstTimeKey, false);
  }
}
