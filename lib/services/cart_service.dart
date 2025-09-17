import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';
import 'local_storage.dart'; // <- your SharedPreferences helper

class CartService {
  static const String baseUrl = 'https://your-server.com/api'; // <-- update

  /// Add a product to the cart
  static Future<bool> addToCart(int productId, int quantity) async {
    final token = await LocalStorage.getAuthToken();
    if (token == null) {
      print('🔴 No token found, user must log in.');
      return false;
    }

    final url = Uri.parse('$baseUrl/cart');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({
      'product_id': productId,
      'quantity': quantity,
    });

    print('🔵 AddToCart URL: $url');
    print('🔵 AddToCart Body: $body');

    final response = await http.post(url, headers: headers, body: body);

    print('🟠 AddToCart Status: ${response.statusCode}');
    print('🟠 AddToCart Response: ${response.body}');

    // ✅ Laravel usually returns 201 on create
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  /// Fetch the current cart
  static Future<List<CartItem>> fetchCart() async {
    final token = await LocalStorage.getAuthToken();

    if (token == null) return [];

    final url = Uri.parse('$baseUrl/cart');
    final response = await http.get(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    print('🔵 ViewCart Status: ${response.statusCode}');
    print('🔵 ViewCart Body:   ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => CartItem.fromJson(e)).toList();
    }
    throw Exception('Failed to load cart');
  }
}
