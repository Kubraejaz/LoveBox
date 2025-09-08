import 'package:flutter/material.dart';
import 'package:lovebox/utils/snackbar_helper.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
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
        color: Color(0xFFF5F5F5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 70),
              child: Text(
                'LoveBox',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF83758),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Create an account',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000000),
                          ),
                        ),
                        SizedBox(height: 25),
                        // Username
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(
                              Icons.person,
                              color: Color(0xFF676767),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            labelStyle: TextStyle(color: Color(0xFF676767)),
                            filled: true,
                            fillColor: Color(0xFFF3F3F3),
                          ),
                          validator:
                              (val) =>
                                  val == null || val.isEmpty
                                      ? "Enter username"
                                      : null,
                        ),
                        SizedBox(height: 20),
                        // Email
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(
                              Icons.email,
                              color: Color(0xFF676767),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            labelStyle: TextStyle(color: Color(0xFF676767)),
                            filled: true,
                            fillColor: Color(0xFFF3F3F3),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator:
                              (val) =>
                                  val == null || !val.contains('@')
                                      ? "Enter valid email"
                                      : null,
                        ),
                        SizedBox(height: 20),
                        // Password
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Color(0xFF676767),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            suffixIcon: Icon(
                              Icons.visibility,
                              color: Color(0xFF676767),
                            ),
                            labelStyle: TextStyle(color: Color(0xFF676767)),
                            filled: true,
                            fillColor: Color(0xFFF3F3F3),
                          ),
                          obscureText: true,
                          validator:
                              (val) =>
                                  val == null || val.length < 6
                                      ? "Min 6 characters"
                                      : null,
                        ),
                        SizedBox(height: 25),
                        RichText(
                          text: TextSpan(
                            text: 'By clicking the ',
                            style: TextStyle(color: Color(0xFF676767)),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Register',
                                style: TextStyle(color: Color(0xFFFF4B26)),
                              ),
                              TextSpan(
                                text: ' button, you agree to the public offer',
                                style: TextStyle(color: Color(0xFF676767)),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        // Create Account button
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

                                      if (authProvider.errorMessage != null) {
                                        // ❌ Use SnackbarHelper for error
                                        SnackbarHelper.showError(
                                          context,
                                          authProvider.errorMessage!,
                                        );
                                      } else {
                                        // ✅ Use SnackbarHelper for success
                                        SnackbarHelper.showSuccess(
                                          context,
                                          "Account created! Please login.",
                                        );

                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => LoginScreen(),
                                          ),
                                        );
                                      }
                                    }
                                  },
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color(0xFFF83758),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Center(
                              child:
                                  authProvider.isLoading
                                      ? CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : Text(
                                        'Create Account',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFFFFFFFF),
                                        ),
                                      ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          '- OR Continue with -',
                          style: TextStyle(color: Color(0xFF575757)),
                        ),
                        SizedBox(height: 10),
                        // Social buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _socialButton('assets/images/search.png'),
                            SizedBox(width: 10),
                            _socialButton(
                              null,
                              icon: Icons.apple,
                              iconColor: Color(0xFF000000),
                            ),
                            SizedBox(width: 10),
                            _socialButton(
                              null,
                              icon: Icons.facebook,
                              iconColor: Color(0xFF3D4DA6),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        // Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "I Already Have an Account ",
                              style: TextStyle(
                                color: Color(0xFF575757),
                                fontSize: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Login",
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
        color: Color(0xFFFCF3F6),
        shape: BoxShape.circle,
        border: Border.all(color: Color(0xFFF83758), width: 2.0),
      ),
      child: IconButton(
        icon:
            image != null
                ? Image.asset(image, height: 30)
                : Icon(icon, color: iconColor, size: 30),
        onPressed: () {},
        padding: EdgeInsets.all(0),
      ),
    );
  }
}
