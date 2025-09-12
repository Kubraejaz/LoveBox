import 'package:flutter/material.dart';
import 'package:lovebox/screens/bottom_navbar_screen.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize AuthProvider first
  final authProvider = AuthProvider();
  await authProvider.loadUserFromLocal();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ],
      child: MyApp(isLoggedIn: authProvider.user != null),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LoveBox',
      theme: ThemeData(primarySwatch: Colors.pink),
      home:
          isLoggedIn
              ? const BottomNavBarScreen(initialIndex: 0)
              : const LoginScreen(),
    );
  }
}
