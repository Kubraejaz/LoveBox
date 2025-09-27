// lib/services/address_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../models/address_model.dart';

class AddressService {
  /// Fetch all addresses for the logged-in user
  static Future<List<AddressModel>> fetchUserAddresses(String token) async {
    final url = Uri.parse('${ApiEndpoints.userProfile}/addresses'); // API endpoint for addresses

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // The addresses may be inside data['data']['addresses'] depending on your API
      final List<dynamic> addressList = (data['data']['addresses'] ?? []);

      return addressList.map((e) => AddressModel.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to fetch addresses: ${response.statusCode} ${response.body}');
    }
  }
}
