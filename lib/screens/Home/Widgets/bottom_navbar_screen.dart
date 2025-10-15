import 'package:flutter/material.dart';
import 'package:lovebox/screens/Core/local_storage.dart';
import 'package:lovebox/screens/Wishlist/Widgets/wishlist-screen.dart';
import 'package:lovebox/screens/Home/Widgets/home_screen.dart';
import 'package:lovebox/screens/Cart/Widgets/cart_screen.dart';
import 'package:lovebox/screens/Profile/Widgets/profile_screen.dart';
import '../../Authentication/Widgets/login_screen.dart';
import '../../../constants/color.dart';

class BottomNavBarScreen extends StatefulWidget {
  final int initialIndex;

  const BottomNavBarScreen({super.key, this.initialIndex = 0});

  @override
  State<BottomNavBarScreen> createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  late int _selectedIndex;

  final List<String> _screenTitles = ["Home", "Cart", "Wishlist", "Profile"];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  Future<void> _onItemTapped(int index) async {
    final loggedIn = await LocalStorage.isLoggedIn();

    // If user is not logged in and taps restricted tabs
    if (!loggedIn && (index == 1 || index == 2 || index == 3)) {
      setState(() => _selectedIndex = index);
      return;
    }

    setState(() => _selectedIndex = index);
  }

  Widget _getScreen(int index) {
    return FutureBuilder<bool>(
      future: LocalStorage.isLoggedIn(),
      builder: (context, snapshot) {
        final loggedIn = snapshot.data ?? false;

        // Restricted tabs: Cart, Wishlist, Profile
        if (!loggedIn && (index == 1 || index == 2 || index == 3)) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                _screenTitles[index],
                style: const TextStyle(
                  color: Colors.white, // White color for AppBar title
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: AppColors.primary,
              centerTitle: true,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 20),
                    Text(
                      "You need to login first to access the ${_screenTitles[index]} section.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        ).then((_) => setState(() {}));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Logged-in or Home tab
        switch (index) {
          case 0:
            return const HomeScreen();
          case 1:
            return const CartScreen();
          case 2:
            return const WishlistScreen();
          case 3:
            return const ProfileScreen();
          default:
            return const HomeScreen();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getScreen(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Wishlist",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
