import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lovebox/screens/Profile/Models/address_model.dart';
import '../../../constants/color.dart';
import '../../../constants/api_endpoints.dart';
import '../Models/user_model.dart';
import '../../Core/local_storage.dart';
import '../../../utils/snackbar_helper.dart';
import 'edit_profile_screen.dart';
import '../../Authentication/Widgets/login_screen.dart';
import 'change_password_screen.dart'; // ✅ Added import

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final cachedUser = await LocalStorage.getUser();
      if (mounted && cachedUser != null) setState(() => _user = cachedUser);

      final token = await LocalStorage.getAuthToken();
      if (token == null || token.isEmpty) return;

      final res = await http.get(
        Uri.parse(ApiEndpoints.userProfile),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final jsonBody = jsonDecode(res.body);
        final user = UserModel.fromJson(jsonBody['data'], token: token);
        await LocalStorage.saveUser(user);
        if (mounted) setState(() => _user = user);
      } else if (res.statusCode == 401) {
        await _logout();
      } else {
        if (mounted) {
          SnackbarHelper.showError(context, 'Failed to load profile');
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Error loading profile: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refreshProfile() async => await _loadProfile();

  Future<void> _openEditProfile() async {
    if (_user == null) return;

    final updatedUser = await Navigator.push<UserModel>(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(user: _user!)),
    );

    if (updatedUser != null && mounted) {
      await LocalStorage.saveUser(updatedUser);
      setState(() => _user = updatedUser);
      await _loadProfile();
      SnackbarHelper.showSuccess(context, 'Profile updated successfully');
    }
  }

  Future<void> _logout() async {
    await LocalStorage.clearAllUserData();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultAddress = _user?.defaultAddress;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        color: AppColors.primary,
        child:
            _loading
                ? Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
                : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    _buildHeader(defaultAddress),
                    const SizedBox(height: 100),
                    _buildActionGrid(),
                    const SizedBox(height: 32),
                  ],
                ),
      ),
    );
  }

  // ---------- Stylish Header ----------
  Widget _buildHeader(AddressModel? defaultAddress) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 260,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.95),
                AppColors.primary.withOpacity(0.75),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(45),
              bottomRight: Radius.circular(45),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: -70,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.white, AppColors.primary.withOpacity(0.2)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                    "https://static.vecteezy.com/system/resources/thumbnails/029/769/642/small/portrait-of-beautiful-muslim-female-student-online-learning-in-coffee-shop-young-woman-with-hijab-studies-with-laptop-in-cafe-girl-doing-her-homework-free-photo.jpeg",
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _user?.name ?? "Guest User",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _infoRow(
                        icon: Icons.email_outlined,
                        text: _user?.email ?? "guest@example.com",
                      ),
                      if (defaultAddress != null) ...[
                        const SizedBox(height: 8),
                        _infoRow(
                          icon: Icons.location_on_outlined,
                          text:
                              '${defaultAddress.address}, ${defaultAddress.city}, ${defaultAddress.state}, ${defaultAddress.country}'
                              '${defaultAddress.postalCode.isNotEmpty ? ', ${defaultAddress.postalCode}' : ''}',
                          isMultiLine: true,
                          iconColor: AppColors.primary,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String text,
    bool isMultiLine = false,
    Color? iconColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment:
          isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: iconColor ?? AppColors.textGrey),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMultiLine ? 14 : 15,
              color: AppColors.textGrey,
              height: isMultiLine ? 1.2 : 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Action Grid ----------
  Widget _buildActionGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _actionCard(Icons.edit, "Edit Profile", _openEditProfile),
          _actionCard(Icons.lock, "Change Password", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            );
          }), // ✅ Clickable
          _actionCard(Icons.shopping_bag, "My Orders", () {}),
          _actionCard(Icons.settings, "Settings", () {}),
          _actionCard(Icons.contact_support, "Contact Us", () {}),
          _actionCard(Icons.logout, "Logout", _logout),
        ],
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
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
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
}
