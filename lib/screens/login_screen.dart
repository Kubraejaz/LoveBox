import 'package:flutter/material.dart';
import 'signup_screen.dart'; // 👈 make sure ye import ho

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFF5F5F5), // Off-white background
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 100),
              // Heading
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
              // Username field
              TextField(
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(
                    Icons.person,
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
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF676767)),
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
              // Forgot Password
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
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF83758),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: const Center(
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFFFFFFF),
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
              // Social buttons (same as Signup)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCF3F6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFF83758),
                        width: 2.0,
                      ),
                    ),
                    child: IconButton(
                      icon: Image.asset(
                        'assets/images/search.png', // Google icon
                        height: 30,
                      ),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCF3F6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFF83758),
                        width: 2.0,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.apple,
                        color: Color(0xFF000000),
                        size: 30,
                      ),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCF3F6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFF83758),
                        width: 2.0,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.facebook,
                        color: Color(0xFF3D4DA6),
                        size: 30,
                      ),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              // Bottom text with clickable Sign Up ✅
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
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Color(0xFFF83758),
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFFF83758), // 👈 underline bhi red
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
