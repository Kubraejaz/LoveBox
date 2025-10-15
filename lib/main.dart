import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lovebox/screens/Authentication/Widgets/splash_screen.dart';
import 'package:lovebox/screens/Authentication/Providers/auth_provider.dart';
import 'package:lovebox/screens/Cart/Providers/cart_provider.dart';
import 'package:lovebox/screens/Wishlist/Providers/whishlist_provider.dart'; // <-- updated

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()), // <-- fixed
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
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
