import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lovebox/screens/Core/local_storage.dart';

import '../../Home/Models/product_model.dart';
import '../../../constants/api_endpoints.dart';

class WishlistService {
  /// Builds the full v1 URL for endpoints
  static String _endpoint(String path) =>
      "${ApiEndpoints.baseApi}/v1$path";

  /// -------------------------------
  ///  GET  /api/v1/wishlist
  /// -------------------------------
  static Future<List<ProductModel>> getWishlist() async {
    final token = await LocalStorage.getAuthToken();
    if (token == null || token.isEmpty) return [];

    final res = await http.get(
      Uri.parse(_endpoint("/wishlist")),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body is List) {
        return body
            .whereType<Map<String, dynamic>>()
            .map((item) =>
                ProductModel.fromJson(item['product'] as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  /// -------------------------------
  ///  POST /api/v1/wishlist/store
  /// -------------------------------
  static Future<bool> addToWishlist(int productId) async {
    final token = await LocalStorage.getAuthToken();
    if (token == null || token.isEmpty) return false;

    final res = await http.post(
      Uri.parse(_endpoint("/wishlist/store")),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'product_id': productId}),
    );

    return res.statusCode == 201;
  }

  /// -------------------------------
  ///  DELETE /api/v1/wishlist/delete/{id}
  /// -------------------------------
  static Future<bool> removeFromWishlist(int wishlistId) async {
    final token = await LocalStorage.getAuthToken();
    if (token == null || token.isEmpty) return false;

    final res = await http.delete(
      Uri.parse(_endpoint("/wishlist/delete/$wishlistId")),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    return res.statusCode == 200;
  }

  /// Helper: find the wishlist row ID for a given product
  static Future<int?> getWishlistId(int productId) async {
    final token = await LocalStorage.getAuthToken();
    if (token == null || token.isEmpty) return null;

    final res = await http.get(
      Uri.parse(_endpoint("/wishlist")),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body is List) {
        for (final item in body) {
          if (item is Map<String, dynamic>) {
            final product = item['product'] as Map<String, dynamic>?;
            if (product != null && product['id'] == productId) {
              return item['wishlist_id'] as int?;
            }
          }
        }
      }
    }
    return null;
  }
}
