import 'package:flutter/material.dart';
import '../constants/color.dart';
import '../services/local_storage.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                "https://static.vecteezy.com/system/resources/thumbnails/029/769/642/small/portrait-of-beautiful-muslim-female-student-online-learning-in-coffee-shop-young-woman-with-hijab-studies-with-laptop-in-cafe-girl-doing-her-homework-free-photo.jpeg",
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Kubra Ejaz",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              "kubra@example.com",
              style: TextStyle(fontSize: 15, color: AppColors.textGrey),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildProfileTile(Icons.edit, "Edit Profile", () {}),
                  _buildProfileTile(Icons.lock, "Change Password", () {}),
                  _buildProfileTile(Icons.shopping_bag, "My Orders", () {}),
                  _buildProfileTile(Icons.settings, "Settings", () {}),
                  _buildProfileTile(Icons.logout, "Logout", () async {
                    await LocalStorage.clearUser();
                    await LocalStorage.saveNavIndex(0); // ✅ reset to Home
                    if (!context.mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }),
                ],
              ),
            ),
          ],
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
