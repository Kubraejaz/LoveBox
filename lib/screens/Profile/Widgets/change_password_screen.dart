// lib/screens/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:lovebox/constants/color.dart';
import '../../../utils/snackbar_helper.dart'; // make sure this path matches your folder

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  void _updatePassword() {
    final current = currentController.text.trim();
    final newPass = newController.text.trim();
    final confirm = confirmController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      SnackbarHelper.showError(context, "Please fill in all fields");
      return;
    }

    if (newPass != confirm) {
      SnackbarHelper.showError(context, "New passwords do not match");
      return;
    }

    // 🔐 Password update logic can be added here (e.g. Firebase or API call)
    SnackbarHelper.showSuccess(context, "Password updated successfully 💕");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          "Change Password",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_rounded,
                color: AppColors.primary,
                size: 70,
              ),
              const SizedBox(height: 20),
              const Text(
                "Reset your password securely",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 35),

              _buildPasswordField(
                controller: currentController,
                hint: "Current Password",
                icon: Icons.lock_outline,
              ),
              const SizedBox(height: 20),

              _buildPasswordField(
                controller: newController,
                hint: "New Password",
                icon: Icons.lock,
              ),
              const SizedBox(height: 20),

              _buildPasswordField(
                controller: confirmController,
                hint: "Confirm New Password",
                icon: Icons.lock_reset,
              ),
              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _updatePassword,
                  child: const Text(
                    "Update Password",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primary),
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textLightGrey),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.primary.withOpacity(0.8),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
