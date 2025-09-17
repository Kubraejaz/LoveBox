import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lovebox/constants/api_endpoints.dart';
import '../models/cart_item.dart';
import 'local_storage.dart';

class CartService {
  /// ➕ Add product to cart
  static Future<bool> addToCart(int productId, int quantity) async {
    final token = await LocalStorage.getAuthToken();
    if (token == null) return false;

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'product_id': productId,
      'quantity': quantity,
    });

    final response = await http.post(
      Uri.parse(ApiEndpoints.addToCart), // ✅ no hard-coded URL
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) return true;

    if (response.statusCode == 422) {
      try {
        final err = jsonDecode(response.body);
        print('⚠️ Validation Error: $err');
      } catch (_) {}
    }
    return false;
  }

  /// 🛒 Fetch cart items
  static Future<List<CartItem>> fetchCart() async {
    final token = await LocalStorage.getAuthToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse(ApiEndpoints.viewCart), // ✅ no hard-coded URL
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => CartItem.fromJson(e)).toList();
    }
    throw Exception('Failed to load cart (status ${response.statusCode})');
  }
}
