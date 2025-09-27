import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lovebox/utils/snackbar_helper.dart';

import '../constants/color.dart';
import '../constants/api_endpoints.dart';
import '../models/user_model.dart';
import '../models/address_model.dart';
import '../services/local_storage.dart';
import '../services/address_service.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _loading = true;
  bool _loadingAddress = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _loadingAddress = true;
    });

    try {
      // Load cached user for instant UI
      final cachedUser = await LocalStorage.getUser();
      if (mounted) setState(() => _user = cachedUser);

      // Fetch fresh user data from backend
      final token = await LocalStorage.getAuthToken();
      if (token == null || token.isEmpty) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final url = Uri.parse(ApiEndpoints.userProfile);
      final res = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'] ?? {};
        final user = UserModel.fromJson(data, token: token);

        // Fetch addresses separately
        final addresses = await AddressService.fetchUserAddresses(token);
        final updatedUser = user.copyWith(addresses: addresses);

        await LocalStorage.saveUser(updatedUser);

        if (mounted) setState(() => _user = updatedUser);
      } else if (res.statusCode == 401) {
        await _logout();
      } else {
        debugPrint('Profile fetch failed: ${res.statusCode} ${res.body}');
        if (mounted)
          SnackbarHelper.showError(context, 'Failed to load profile');
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) SnackbarHelper.showError(context, 'Error loading profile');
    } finally {
      if (mounted)
        setState(() {
          _loading = false;
          _loadingAddress = false;
        });
    }
  }

  Future<void> _refreshProfile() async {
    await _loadProfile();
  }

  Future<void> _openEditProfile() async {
    if (_user == null) return;

    final updatedUser = await Navigator.push<UserModel>(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(user: _user!)),
    );

    if (updatedUser != null && mounted) {
      // Save updated token in case password/email changed
      if (updatedUser.token != _user!.token) {
        await LocalStorage.saveAuthToken(updatedUser.token);
      }

      setState(() => _user = updatedUser);

      // ✅ Show success snackbar
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
        backgroundColor: Colors.white,
        child:
            _loading
                ? Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
                : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    _buildHeader(defaultAddress),
                    const SizedBox(height: 90),
                    _buildActionGrid(),
                    const SizedBox(height: 32),
                  ],
                ),
      ),
    );
  }

  Widget _buildHeader(AddressModel? defaultAddress) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
        ),
        Positioned(
          left: 20,
          bottom: -50,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(
                  "https://static.vecteezy.com/system/resources/thumbnails/029/769/642/small/portrait-of-beautiful-muslim-female-student-online-learning-in-coffee-shop-young-woman-with-hijab-studies-with-laptop-in-cafe-girl-doing-her-homework-free-photo.jpeg",
                ),
              ),
              const SizedBox(width: 16),
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
                    if (defaultAddress != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          '${defaultAddress.address}, ${defaultAddress.city}, ${defaultAddress.state}, ${defaultAddress.country}${defaultAddress.postalCode.isNotEmpty ? ', ${defaultAddress.postalCode}' : ''}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textGrey,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _actionCard(Icons.edit, "Edit Profile", _openEditProfile),
          _actionCard(Icons.lock, "Change Password", () {}),
          _actionCard(Icons.shopping_bag, "My Orders", () {}),
          _actionCard(Icons.settings, "Setting", () {}),
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
}
