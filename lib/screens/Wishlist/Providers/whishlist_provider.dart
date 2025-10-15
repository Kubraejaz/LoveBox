import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lovebox/screens/Core/local_storage.dart';

import '../../Home/Models/product_model.dart';
import '../../../constants/api_endpoints.dart';

class WishlistProvider with ChangeNotifier {
  final List<ProductModel> _wishlist = [];
  final List<int> _wishlistIds = []; // wishlist row IDs from API

  List<ProductModel> get wishlist => List.unmodifiable(_wishlist);

  bool isInWishlist(int productId) =>
      _wishlist.any((p) => p.id == productId);

  // ---------------- Load ----------------
  Future<void> loadWishlist() async {
    final token = await LocalStorage.getAuthToken();
    if (token == null || token.isEmpty) {
      _wishlist.clear();
      _wishlistIds.clear();
      notifyListeners();
      return;
    }

    try {
      final res = await http.get(
        Uri.parse(ApiEndpoints.wishlist),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        _wishlist
          ..clear()
          ..addAll(data.map((e) => ProductModel.fromJson(e['product'])));
        _wishlistIds
          ..clear()
          ..addAll(data.map<int>((e) => e['wishlist_id']));
      } else {
        _wishlist.clear();
        _wishlistIds.clear();
      }
    } catch (_) {
      _wishlist.clear();
      _wishlistIds.clear();
    }
    notifyListeners();
  }

  // ---------------- Add ----------------
  Future<void> addToWishlist(ProductModel product) async {
    final token = await LocalStorage.getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('Login required');
    }

    final res = await http.post(
      Uri.parse(ApiEndpoints.addWishlist),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'product_id': product.id}),
    );

    if (res.statusCode == 201) {
      final data = jsonDecode(res.body);
      _wishlist.add(product);
      _wishlistIds.add(data['id']); // store wishlist row ID
      notifyListeners();
    } else {
      final msg = _parseMsg(res.body) ?? 'Failed to add to wishlist';
      throw Exception(msg);
    }
  }

  // ---------------- Remove ----------------
  Future<void> removeFromWishlist(ProductModel product) async {
    final token = await LocalStorage.getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('Login required');
    }

    final index = _wishlist.indexWhere((p) => p.id == product.id);
    if (index == -1) throw Exception('Item not found in wishlist');

    final wishlistId = _wishlistIds[index];

    final res = await http.delete(
      Uri.parse('${ApiEndpoints.deleteWishlist}/$wishlistId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      _wishlist.removeAt(index);
      _wishlistIds.removeAt(index);
      notifyListeners();
    } else {
      final msg = _parseMsg(res.body) ?? 'Failed to remove from wishlist';
      throw Exception(msg);
    }
  }

  String? _parseMsg(String body) {
    try {
      final json = jsonDecode(body);
      return json['message']?.toString();
    } catch (_) {
      return null;
    }
  }
}
