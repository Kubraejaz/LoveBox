import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lovebox/screens/bottom_navbar_screen.dart';
import '../constants/api_endpoints.dart';
import '../constants/color.dart';
import '../constants/strings.dart';
import 'signup_screen.dart';
import '../services/local_storage.dart';
import '../models/user_model.dart';
import '../utils/snackbar_helper.dart';

// ✅ Added import for forgot password screen
import 'forgot_password_screen.dart';

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
      SnackbarHelper.showError(context, AppStrings.fillAllFields);
      return;
    }

    setState(() => _isLoading = true);

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
        SnackbarHelper.showError(context, AppStrings.emptyResponse);
        setState(() => _isLoading = false);
        return;
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['token'] != null &&
          data['user'] != null) {
        final token = data['token'] as String;
        final userMap = Map<String, dynamic>.from(data['user']);

        await LocalStorage.saveAuthToken(token);

        final user = UserModel.fromJson({...userMap, 'token': token});
        await LocalStorage.saveUser(user);

        await LocalStorage.resetNavIndex();

        if (!mounted) return;

        SnackbarHelper.showSuccess(
          context,
          data['message'] ?? AppStrings.loginSuccess,
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const BottomNavBarScreen(initialIndex: 0),
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        final errorMessage = data['message'] ?? AppStrings.loginFailed;
        SnackbarHelper.showError(context, errorMessage);
      }
    } catch (e) {
      SnackbarHelper.showError(context, "${AppStrings.error}: $e");
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppStrings.welcomeBack,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email Field
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: AppStrings.email,
                      prefixIcon: const Icon(
                        Icons.email,
                        color: AppColors.textGrey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      labelStyle: const TextStyle(color: AppColors.textGrey),
                      filled: true,
                      fillColor: AppColors.inputFill,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: AppStrings.password,
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: AppColors.textGrey,
                      ),
                      suffixIcon: const Icon(
                        Icons.visibility,
                        color: AppColors.textGrey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      labelStyle: const TextStyle(color: AppColors.textGrey),
                      filled: true,
                      fillColor: AppColors.inputFill,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ✅ Navigate to Forgot Password Screen
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        AppStrings.forgotPassword,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Login Button
                  GestureDetector(
                    onTap: _isLoading ? null : _loginUser,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                AppStrings.loginButton,
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
                    AppStrings.orContinue,
                    style: TextStyle(color: AppColors.textLightGrey),
                  ),
                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialButton(image: 'assets/images/search.png'),
                      const SizedBox(width: 12),
                      _socialButton(
                        icon: Icons.apple,
                        color: AppColors.textDark,
                      ),
                      const SizedBox(width: 12),
                      _socialButton(
                        icon: Icons.facebook,
                        color: AppColors.facebookBlue,
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        AppStrings.createAccountLogin,
                        style: TextStyle(
                          color: AppColors.textLightGrey,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          AppStrings.signUp,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),

            // ✅ Top-right cross button
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const BottomNavBarScreen(initialIndex: 0),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black12,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialButton({String? image, IconData? icon, Color? color}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.socialButton,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2.0),
      ),
      child: IconButton(
        icon: image != null
            ? Image.asset(image, height: 30)
            : Icon(icon, color: color, size: 30),
        onPressed: () {},
        padding: EdgeInsets.zero,
      ),
    );
  }
}
