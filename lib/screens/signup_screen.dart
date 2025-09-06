import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFF5F5F5), // Off-white background color
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align to start (left) for "LoveBox"
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40.0, left: 0),
                child: Text(
                  'LoveBox',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF83758),
                  ),
                ),
              ),

              SizedBox(
                height: 15,
              ), // Space between LoveBox and Create an account

              Expanded(
                child: SingleChildScrollView(
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
                      // Username field
                      TextField(
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
                      ),
                      SizedBox(height: 20),
                      // Email field
                      TextField(
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
                      ),
                      SizedBox(height: 20),
                      // Password field
                      TextField(
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
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color(0xFFF83758),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Center(
                            child: Text(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color(0xFFFCF3F6),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xFFF83758),
                                width: 2.0,
                              ),
                            ),
                            child: IconButton(
                              icon: Image.asset(
                                'assets/images/search.png',
                                height: 30,
                              ),
                              onPressed: () {},
                              padding: EdgeInsets.all(0),
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color(0xFFFCF3F6),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xFFF83758),
                                width: 2.0,
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.apple,
                                color: Color(0xFF000000),
                                size: 30,
                              ),
                              onPressed: () {},
                              padding: EdgeInsets.all(0),
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color(0xFFFCF3F6),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xFFF83758),
                                width: 2.0,
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.facebook,
                                color: Color(0xFF3D4DA6),
                                size: 30,
                              ),
                              onPressed: () {},
                              padding: EdgeInsets.all(0),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      RichText(
                        text: TextSpan(
                          text: 'I Already Have an Account ',
                          style: TextStyle(
                            color: Color(0xFF575757),
                            fontSize: 16,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Login',
                              style: TextStyle(
                                color: Color(0xFFF83758),
                                decoration: TextDecoration.underline,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
