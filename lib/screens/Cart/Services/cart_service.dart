import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/cart_item.dart';
import '../../Core/local_storage.dart';
import '../../../constants/api_endpoints.dart';

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Unauthorized']);
  @override
  String toString() => message;
}

class CartService {
  /// 🔹 Fetch all cart items
  static Future<List<CartItem>> fetchCart() async {
    final token = await LocalStorage.getAuthToken();
    if (token == null || token.isEmpty) throw UnauthorizedException();

    final response = await http.get(
      Uri.parse(ApiEndpoints.viewCart),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = _safeJsonDecode(response.body);
      final List<dynamic> list =
          decoded is List ? decoded : (decoded['data'] as List? ?? []);
      return list
          .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (response.statusCode == 401) throw UnauthorizedException();
    throw Exception('Failed to fetch cart: ${response.statusCode}');
  }

  /// 🔹 Add product to cart (returns structured response)
  /// Returns: { "success": bool, "message": String, "statusCode": int? }
  static Future<Map<String, dynamic>> addToCart(int productId, int quantity) async {
    final token = await LocalStorage.getAuthToken();
    if (token == null || token.isEmpty) throw UnauthorizedException();

    final response = await http.post(
      Uri.parse(ApiEndpoints.addToCart),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'product_id': productId,
        'quantity': quantity,
      }),
    );

    final decoded = _safeJsonDecode(response.body);
    final message = (decoded is Map && decoded['message'] != null)
        ? decoded['message'].toString()
        : 'Item added to cart';

    final success = (response.statusCode == 200 || response.statusCode == 201);

    if (response.statusCode == 401) throw UnauthorizedException();

    return {
      'success': success,
      'message': message,
      'statusCode': response.statusCode,
      'data': decoded is Map && decoded.containsKey('data') ? decoded['data'] : null,
    };
  }

  /// 🔹 Remove product from cart
  static Future<bool> removeItem(int cartId) async {
    final token = await LocalStorage.getAuthToken();
    if (token == null || token.isEmpty) throw UnauthorizedException();

    final url = Uri.parse('${ApiEndpoints.baseApi}/cart/$cartId');
    final response = await http.delete(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) return true;
    if (response.statusCode == 401) throw UnauthorizedException();

    print('❌ RemoveItem Failed: ${response.statusCode} ${response.body}');
    throw Exception('Failed to remove cart item');
  }

  /// 🔸 Safe JSON decoder (avoids crash on invalid or empty body)
  static dynamic _safeJsonDecode(String source) {
    try {
      if (source.trim().isEmpty) return {};
      return jsonDecode(source);
    } catch (e) {
      print('⚠️ JSON Decode Error: $e -- raw: $source');
      return {};
    }
  }
}
