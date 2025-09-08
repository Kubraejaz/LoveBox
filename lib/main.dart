import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/local_storage.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final isFirst = await LocalStorage.isFirstTime();
    if (isFirst) {
      return SignupScreen(); // ✅ First time -> SignupScreen
    }

    final user = await LocalStorage.getUser();
    if (user['token'] != null && user['token']!.isNotEmpty) {
      return HomeScreen(); // ✅ Already logged in -> HomeScreen
    }

    return LoginScreen(); // ✅ Signed up but not logged in -> LoginScreen
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoveBox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFF83758),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF83758)),
      ),
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return const Scaffold(
              body: Center(child: Text("Error loading app")),
            );
          }
          return snapshot.data!;
        },
      ),
    );
  }
}
