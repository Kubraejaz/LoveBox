import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(
    0xFFF83758,
  ); // Main accent / buttons / price
  static const Color background = Color(0xFFF5F5F5); // Screen background
  static const Color textDark = Color(0xFF000000); // Titles / main text
  static const Color textGrey = Color(
    0xFF676767,
  ); // Secondary text / description
  static const Color textLightGrey = Color(0xFF575757); // Light grey text
  static const Color inputFill = Color(0xFFF3F3F3); // Input field background
  static const Color socialButton = Color(0xFFFCF3F6); // Social login buttons
  static const Color facebookBlue = Color(0xFF3D4DA6); // Facebook button
  static const Color brokenImage = Color(
    0xFFE0E0E0,
  ); // Fallback for broken images
  static const Color dialogYes = Color(
    0xFFFFFFFF,
  ); // Logout dialog Yes button background
  static const Color dialogNo = Color(
    0xFF9E9E9E,
  ); // Logout dialog No button background
  static const Color dialogPressed = Color(0xFFFFA3B1); // Pinkish pressed state

  // ✅ New additions for consistency
  static const Color border = Color(0xFFBDBDBD); // Borders for inputs/cards
  static const Color iconSecondary = Color(
    0xFF9E9E9E,
  ); // Subtle icons (like search)
  static const Color textSecondary = Color(
    0xFF9E9E9E,
  ); // Placeholder / hint text

  // 🔹 Add these for the profile screen design
  static const Color cardBackground = Colors.white; // Card fill color
  static const Color shadow = Colors.black26; // Default card shadow
}
