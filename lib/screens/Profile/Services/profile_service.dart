import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constants/api_endpoints.dart';

class ProfileService {
  /// ✅ Fetch the current user's profile
  static Future<Map<String, dynamic>> fetchProfile(String token) async {
    final url = Uri.parse(ApiEndpoints.userProfile);

    final res = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    if (res.statusCode == 401) {
      throw Exception('Unauthorized – please log in again.');
    }

    throw Exception('Failed to load profile (status ${res.statusCode}): ${res.body}');
  }

  /// ✅ Update profile details (e.g. name, email, etc.)
  static Future<bool> updateProfile(
    String token,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse(ApiEndpoints.updateProfile);

    final res = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      print('Profile update failed: ${res.statusCode} ${res.body}');
    }

    return res.statusCode == 200;
  }

  /// ✅ Update a specific address
  /// Pass [addressId] if your backend needs it in the URL.
  static Future<bool> updateAddress(
    String token,
    Map<String, dynamic> body, {
    String? addressId,
  }) async {
    final endpoint = (addressId != null && addressId.isNotEmpty)
        ? '${ApiEndpoints.updateAddress}/$addressId'
        : ApiEndpoints.updateAddress;

    final url = Uri.parse(endpoint);

    final res = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      print('Address update failed: ${res.statusCode} ${res.body}');
    }

    return res.statusCode == 200;
  }
}
