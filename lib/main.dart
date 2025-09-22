import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lovebox/screens/splash_screen.dart';
import 'package:lovebox/providers/auth_provider.dart';
import 'package:lovebox/providers/cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  final cartProvider = CartProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LoveBox',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const SplashScreen(), // First screen
    );
  }
}
