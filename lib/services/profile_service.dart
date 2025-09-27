import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../constants/api_endpoints.dart';

class ProfileService {
  /// Fetch the user profile
  static Future<UserModel> fetchProfile(String token) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/profile');
    debugPrint('➡️ GET $url');

    final res = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint('⬅️ Status code: ${res.statusCode}');
    debugPrint('⬅️ Response: ${res.body}');

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final userMap = (data['data'] ?? data) as Map<String, dynamic>;
      return UserModel.fromJson(userMap, token: token);
    } else if (res.statusCode == 401) {
      throw Exception('Unauthorized. Token may be invalid or expired.');
    } else {
      throw Exception(
          'Failed to fetch profile: ${res.statusCode} ${res.body}');
    }
  }
}
