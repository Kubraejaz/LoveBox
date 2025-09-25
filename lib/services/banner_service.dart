// lib/services/banner_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lovebox/constants/api_endpoints.dart';
import '../models/banner_model.dart';

class BannerService {
  static Future<List<BannerModel>> fetchBanners() async {
    // Call the full URL from ApiEndpoints
    final response = await http.get(Uri.parse(ApiEndpoints.banners));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => BannerModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load banners: ${response.statusCode}');
    }
  }
}
