import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/local_storage.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final userMap = await LocalStorage.getUser();
  final bool isLoggedIn = (userMap['id'] ?? '').isNotEmpty;

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MyApp(isLoggedIn: isLoggedIn),
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
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
