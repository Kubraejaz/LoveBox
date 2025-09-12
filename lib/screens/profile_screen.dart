import 'package:flutter/material.dart';
import '../constants/color.dart';
import '../services/local_storage.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
// ✅ still reuse helper

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await LocalStorage.getUser();
    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  Future<void> _refreshProfile() async {
    // ✅ refresh silently (no snackbar)
    await _loadUser();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        color: AppColors.primary,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  _user != null
                      ? "https://static.vecteezy.com/system/resources/thumbnails/029/769/642/small/portrait-of-beautiful-muslim-female-student-online-learning-in-coffee-shop-young-woman-with-hijab-studies-with-laptop-in-cafe-girl-doing-her-homework-free-photo.jpeg"
                      : "https://via.placeholder.com/150",
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _user?.name ?? "Guest User",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _user?.email ?? "guest@example.com",
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 20),

              // Profile Actions
              _buildProfileTile(Icons.edit, "Edit Profile", () {}),
              _buildProfileTile(Icons.lock, "Change Password", () {}),
              _buildProfileTile(Icons.shopping_bag, "My Orders", () {}),
              _buildProfileTile(Icons.settings, "Settings", () {}),
              _buildProfileTile(Icons.logout, "Logout", () async {
                await LocalStorage.clearUser();
                await LocalStorage.resetNavIndex();
                if (!mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              }),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary, size: 26),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: AppColors.textGrey,
        ),
        onTap: onTap,
      ),
    );
  }
}
