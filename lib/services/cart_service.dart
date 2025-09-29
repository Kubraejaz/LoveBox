import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';
import '../services/local_storage.dart';
import '../constants/api_endpoints.dart';

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Unauthorized']);
  @override
  String toString() => message;
}

class CartService {
  static Future<List<CartItem>> fetchCart() async {
    final token = await LocalStorage.getAuthToken();
    if (token == null || token.isEmpty) throw UnauthorizedException();

    final response = await http.get(
      Uri.parse(ApiEndpoints.viewCart),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> list = decoded is List ? decoded : (decoded['data'] as List? ?? []);
      return list.map((e) => CartItem.fromJson(Map<String, dynamic>.from(e))).toList();
    }

    if (response.statusCode == 401) throw UnauthorizedException();
    throw Exception('Failed to fetch cart');
  }

  static Future<bool> removeItem(int cartId) async {
    final token = await LocalStorage.getAuthToken();
    if (token == null || token.isEmpty) throw UnauthorizedException();

    final url = Uri.parse('${ApiEndpoints.baseApi}/cart/$cartId');
    final response = await http.delete(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200 || response.statusCode == 204) return true;
    if (response.statusCode == 401) throw UnauthorizedException();
    throw Exception('Failed to remove cart item');
  }
}
