import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../models/product_model.dart';

class ProductService {
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiEndpoints.products),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.body.isEmpty) {
        throw Exception("Empty response from server.");
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['success'] == true &&
          data['data'] != null) {
        final List<dynamic> productList = data['data'];
        return productList.map((item) => ProductModel.fromJson(item)).toList();
      }

      if (data['message'] != null) {
        throw Exception(data['message']);
      } else {
        throw Exception("Failed to fetch products. Please try again.");
      }
    } on SocketException {
      throw Exception("No internet connection. Please check your network.");
    } on TimeoutException {
      throw Exception("Request timed out. Please try again.");
    } on FormatException {
      throw Exception("Invalid response format from server.");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }
}
