import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lovebox/constants/api_endpoints.dart';
import 'package:lovebox/screens/home_screen.dart';
import 'package:lovebox/screens/signup_screen.dart';
import 'package:lovebox/services/local_storage.dart';
import 'package:lovebox/models/user_model.dart';
import 'package:lovebox/utils/snackbar_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _loginUser() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      SnackbarHelper.showError(context, "Please fill all fields");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      if (response.body.isEmpty) {
        SnackbarHelper.showError(context, "Empty response from server");
        setState(() => _isLoading = false);
        return;
      }

      final data = jsonDecode(response.body);
      print("Login response: $data"); // 🔎 Debugging

      // ✅ Fix: Check "token" + "user" instead of "success"
      if (response.statusCode == 200 &&
          data['token'] != null &&
          data['user'] != null) {
        final user = UserModel.fromJson({
          ...data['user'],
          "token": data['token'], // ✅ Add token into user object
        });

        await LocalStorage.saveUser(user.id, user.name, user.email, user.token);

        if (!mounted) return;

        SnackbarHelper.showSuccess(
          context,
          data['message'] ?? "Login successful",
        );

        // ✅ Proper navigation to HomeScreen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        String errorMessage = "Login failed";
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            errorMessage = firstError[0];
          } else {
            errorMessage = firstError.toString();
          }
        } else if (data['message'] != null) {
          errorMessage = data['message'];
        }
        SnackbarHelper.showError(context, errorMessage);
      }
    } catch (e) {
      SnackbarHelper.showError(context, "Error: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 80),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF000000),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Email
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Color(0xFF676767),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    labelStyle: const TextStyle(color: Color(0xFF676767)),
                    filled: true,
                    fillColor: const Color(0xFFF3F3F3),
                  ),
                ),
                const SizedBox(height: 20),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Color(0xFF676767),
                    ),
                    suffixIcon: const Icon(
                      Icons.visibility,
                      color: Color(0xFF676767),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    labelStyle: const TextStyle(color: Color(0xFF676767)),
                    filled: true,
                    fillColor: const Color(0xFFF3F3F3),
                  ),
                ),
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Color(0xFFF83758), fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Login button
                GestureDetector(
                  onTap: _isLoading ? null : _loginUser,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF83758),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Center(
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                const Text(
                  '- OR Continue with -',
                  style: TextStyle(color: Color(0xFF575757)),
                ),
                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialButton(image: 'assets/images/search.png'),
                    const SizedBox(width: 12),
                    _socialButton(icon: Icons.apple, color: Color(0xFF000000)),
                    const SizedBox(width: 12),
                    _socialButton(
                      icon: Icons.facebook,
                      color: Color(0xFF3D4DA6),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Create An Account ",
                      style: TextStyle(color: Color(0xFF575757), fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignupScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Color(0xFFF83758),
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFF83758),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton({String? image, IconData? icon, Color? color}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFFCF3F6),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF83758), width: 2.0),
      ),
      child: IconButton(
        icon:
            image != null
                ? Image.asset(image, height: 30)
                : Icon(icon, color: color, size: 30),
        onPressed: () {},
        padding: EdgeInsets.zero,
      ),
    );
  }
}
