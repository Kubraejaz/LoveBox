import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/snackbar_helper.dart';
import 'login_screen.dart';
import '../constants/color.dart';
import '../constants/strings.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        color: AppColors.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 70),
              child: Text(
                AppStrings.appName,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          AppStrings.createAccount,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 25),
                        // Username
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: AppStrings.username,
                            prefixIcon: const Icon(
                              Icons.person,
                              color: AppColors.textGrey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            labelStyle: const TextStyle(
                              color: AppColors.textGrey,
                            ),
                            filled: true,
                            fillColor: AppColors.inputFill,
                          ),
                          validator:
                              (val) =>
                                  val == null || val.isEmpty
                                      ? AppStrings.usernameValidator
                                      : null,
                        ),
                        const SizedBox(height: 20),
                        // Email
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: AppStrings.email,
                            prefixIcon: const Icon(
                              Icons.email,
                              color: AppColors.textGrey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            labelStyle: const TextStyle(
                              color: AppColors.textGrey,
                            ),
                            filled: true,
                            fillColor: AppColors.inputFill,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator:
                              (val) =>
                                  val == null || !val.contains('@')
                                      ? AppStrings.emailValidator
                                      : null,
                        ),
                        const SizedBox(height: 20),
                        // Password
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: AppStrings.password,
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: AppColors.textGrey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            suffixIcon: const Icon(
                              Icons.visibility,
                              color: AppColors.textGrey,
                            ),
                            labelStyle: const TextStyle(
                              color: AppColors.textGrey,
                            ),
                            filled: true,
                            fillColor: AppColors.inputFill,
                          ),
                          obscureText: true,
                          validator:
                              (val) =>
                                  val == null || val.length < 6
                                      ? AppStrings.passwordValidator
                                      : null,
                        ),
                        const SizedBox(height: 25),
                        RichText(
                          text: const TextSpan(
                            text: AppStrings.registerAgreement,
                            style: TextStyle(color: AppColors.textGrey),
                            children: <TextSpan>[
                              TextSpan(
                                text: AppStrings.registerButton,
                                style: TextStyle(color: AppColors.primary),
                              ),
                              TextSpan(
                                text: AppStrings.registerAgreement2,
                                style: TextStyle(color: AppColors.textGrey),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        GestureDetector(
                          onTap:
                              authProvider.isLoading
                                  ? null
                                  : () async {
                                    if (_formKey.currentState!.validate()) {
                                      await authProvider.register(
                                        _nameController.text.trim(),
                                        _emailController.text.trim(),
                                        _passwordController.text.trim(),
                                      );

                                      // Show server-side error like duplicate email
                                      if (authProvider.errorMessage != null) {
                                        SnackbarHelper.showError(
                                          context,
                                          authProvider.errorMessage!,
                                        );
                                      }
                                      // Success case
                                      else if (authProvider.user != null) {
                                        SnackbarHelper.showSuccess(
                                          context,
                                          AppStrings.accountCreated,
                                        );

                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const LoginScreen(),
                                          ),
                                        );
                                      }
                                    }
                                  },
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Center(
                              child:
                                  authProvider.isLoading
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : const Text(
                                        AppStrings.createAccountButton,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          AppStrings.orContinue,
                          style: TextStyle(color: AppColors.textLightGrey),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _socialButton('assets/images/search.png'),
                            const SizedBox(width: 10),
                            _socialButton(
                              null,
                              icon: Icons.apple,
                              iconColor: Colors.black,
                            ),
                            const SizedBox(width: 10),
                            _socialButton(
                              null,
                              icon: Icons.facebook,
                              iconColor: AppColors.facebookBlue,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              AppStrings.alreadyAccount,
                              style: TextStyle(
                                color: AppColors.textLightGrey,
                                fontSize: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                AppStrings.login,
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialButton(String? image, {IconData? icon, Color? iconColor}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.socialButton,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2.0),
      ),
      child: IconButton(
        icon:
            image != null
                ? Image.asset(image, height: 30)
                : Icon(icon, color: iconColor, size: 30),
        onPressed: () {},
        padding: EdgeInsets.zero,
      ),
    );
  }
}
