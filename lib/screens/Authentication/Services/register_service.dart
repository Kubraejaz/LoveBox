import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../constants/api_endpoints.dart';
import '../../Profile/Models/user_model.dart';

class ApiService {
  Future<UserModel> register(String name, String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiEndpoints.register),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.body.isEmpty) {
        throw Exception("Empty response from server.");
      }

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true &&
          data['user'] != null) {
        return UserModel.fromJson(data['user']);
      }

      if (data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        throw Exception(errors.values.first[0]);
      } else if (data['message'] != null) {
        throw Exception(data['message']);
      } else {
        throw Exception("Signup failed. Please try again.");
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

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiEndpoints.login),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.body.isEmpty) {
        throw Exception("Empty response from server.");
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['success'] == true &&
          data['user'] != null) {
        return UserModel.fromJson(data['user']);
      }

      if (data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        throw Exception(errors.values.first[0]);
      } else if (data['message'] != null) {
        throw Exception(data['message']);
      } else {
        throw Exception("Login failed. Please check your credentials.");
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
