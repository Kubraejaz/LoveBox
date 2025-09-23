import 'package:flutter/material.dart';
import '../constants/color.dart';
import '../services/local_storage.dart';
import '../models/user_model.dart';
import 'login_screen.dart';

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
    if (mounted) setState(() => _user = user);
  }

  Future<void> _refreshProfile() async {
    await _loadUser();
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        color: AppColors.primary,
        backgroundColor: Colors.white,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // ======== Gradient Header with Overlap ========
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Gradient background
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                ),
                // Angled overlay shape
                Positioned(
                  right: -50,
                  top: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                // Avatar & info card
                Positioned(
                  left: 20,
                  bottom: -50,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(
                          _user != null
                              ? "https://static.vecteezy.com/system/resources/thumbnails/029/769/642/small/portrait-of-beautiful-muslim-female-student-online-learning-in-coffee-shop-young-woman-with-hijab-studies-with-laptop-in-cafe-girl-doing-her-homework-free-photo.jpeg"
                              : "https://via.placeholder.com/150",
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Glass-like info card
                      Container(
                        padding: const EdgeInsets.all(12),
                        width: MediaQuery.of(context).size.width * 0.55,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _user?.name ?? "Guest User",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _user?.email ?? "guest@example.com",
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 90),

            // ======== Action Grid ========
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _actionCard(Icons.edit, "Edit Profile", () {}),
                  _actionCard(Icons.lock, "Change Password", () {}),
                  _actionCard(Icons.shopping_bag, "My Orders", () {}),
                  _actionCard(Icons.settings, "Setting", () {}),
                  _actionCard(Icons.contact_support, "Contact Us", () {}),
                  _actionCard(Icons.logout, "Logout", _logout),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 56) / 2,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await LocalStorage.clearUser();
    await LocalStorage.clearAuthToken();
    await LocalStorage.resetNavIndex();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
