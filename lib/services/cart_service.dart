import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/cart_item.dart';
import '../models/api_response.dart';
import '../services/auth_service.dart';
import '../constants/api_endpoints.dart';

class CartService {
  // Add item to cart
  static Future<ApiResponse<CartItem>> addToCart(int productId, int quantity) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse<CartItem>(
          success: false,
          message: 'Login required',
          statusCode: 401,
        );
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.addToCart),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'product_id': productId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final cartItem = CartItem.fromJson(data['cart_item']);
        return ApiResponse<CartItem>(
          success: true,
          message: data['message'] ?? 'Item added to cart',
          data: cartItem,
          statusCode: response.statusCode,
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse<CartItem>(
          success: false,
          message: errorData['message'] ?? 'Failed to add item',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<CartItem>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Get cart items
  static Future<ApiResponse<List<CartItem>>> getCartItems() async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse<List<CartItem>>(
          success: false,
          message: 'Login required',
          statusCode: 401,
        );
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.viewCart),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final cartItems = data.map((e) => CartItem.fromJson(e)).toList();
        return ApiResponse<List<CartItem>>(
          success: true,
          message: 'Cart loaded successfully',
          data: cartItems,
          statusCode: response.statusCode,
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse<List<CartItem>>(
          success: false,
          message: errorData['message'] ?? 'Failed to load cart',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<List<CartItem>>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
