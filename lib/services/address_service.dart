import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../models/address_model.dart';

class AddressService {
  /// ✅ Fetch all addresses for the logged-in user
  static Future<List<AddressModel>> fetchUserAddresses(String token) async {
    final url = Uri.parse(ApiEndpoints.fetchAddresses);

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      // Handle different possible JSON shapes
      final List<dynamic> addressList;
      if (body is List) {
        addressList = body;
      } else if (body['data'] is List) {
        addressList = body['data'];
      } else if (body['data']?['addresses'] is List) {
        addressList = body['data']['addresses'];
      } else {
        throw Exception('Unexpected address response format');
      }

      return addressList
          .map<AddressModel>((e) => AddressModel.fromJson(e))
          .toList();
    }

    if (response.statusCode == 401) {
      throw Exception('Unauthorized – please log in again.');
    }

    throw Exception(
      'Failed to fetch addresses '
      '(status ${response.statusCode}): ${response.body}',
    );
  }
}
