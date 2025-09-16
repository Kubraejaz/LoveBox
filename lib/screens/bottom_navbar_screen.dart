import 'package:flutter/material.dart';
import 'package:lovebox/screens/favourite-screen.dart';
import 'package:lovebox/screens/home_screen.dart';
import 'package:lovebox/screens/cart_screen.dart';
import 'package:lovebox/screens/profile_screen.dart';
import 'package:lovebox/services/local_storage.dart';
import 'login_screen.dart';
import '../constants/color.dart';

class BottomNavBarScreen extends StatefulWidget {
  final int initialIndex;

  const BottomNavBarScreen({super.key, this.initialIndex = 0});

  @override
  State<BottomNavBarScreen> createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  late int _selectedIndex;
  final List<Widget> _screens = const [
    HomeScreen(),
    CartScreen(),
    FavouriteScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  Future<void> _onItemTapped(int index) async {
    // Check login if user taps on Cart or Favourite
    if ((index == 1 || index == 2)) {
      final loggedIn = await LocalStorage.isLoggedIn();
      if (!loggedIn) {
        _showLoginDialog();
        return; // Prevent switching tab
      }
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Login Required'),
            content: const Text('You need to login to access this section.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ).then((_) {
                    // After login, reload the state to show Cart/Favourite
                    setState(() {});
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favourite",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
