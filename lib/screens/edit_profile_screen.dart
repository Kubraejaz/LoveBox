import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lovebox/constants/color.dart';
import '../constants/api_endpoints.dart';
import '../models/user_model.dart';
import '../models/address_model.dart';
import '../services/local_storage.dart';
import '../utils/snackbar_helper.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _postalController = TextEditingController();

  bool _isSaving = false;
  AddressModel? _defaultAddress;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);

    _defaultAddress =
        widget.user.defaultAddress ??
        (widget.user.addresses.isNotEmpty ? widget.user.addresses.first : null);

    if (_defaultAddress != null) {
      _addressController.text = _defaultAddress!.address;
      _cityController.text = _defaultAddress!.city;
      _stateController.text = _defaultAddress!.state;
      _countryController.text = _defaultAddress!.country;
      _postalController.text = _defaultAddress!.postalCode;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final token = await LocalStorage.getAuthToken();
      if (token == null) {
        SnackbarHelper.showError(context, 'Token not found');
        return;
      }

      // ------------------- 1️⃣ Update User Profile -------------------
      final profileBody = jsonEncode({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
      });

      final profileRes = await http.put(
        Uri.parse(ApiEndpoints.updateProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: profileBody,
      );

      if (profileRes.statusCode != 200) {
        final body = jsonDecode(profileRes.body);
        final msg =
            body['message'] ??
            (body['errors'] != null
                ? body['errors'].values.map((e) => e.join(', ')).join('\n')
                : 'Failed to update profile');
        SnackbarHelper.showError(context, msg);
        return;
      }

      // ------------------- 2️⃣ Update Default Address -------------------
      final addressBody = jsonEncode({
        if (_defaultAddress?.id != null) 'id': _defaultAddress!.id,
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'country': _countryController.text.trim(),
        'postal_code': _postalController.text.trim(),
        'is_default': true,
      });

      final addressRes = await http.put(
        Uri.parse(ApiEndpoints.updateAddress),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: addressBody,
      );

      if (addressRes.statusCode != 200) {
        final body = jsonDecode(addressRes.body);
        final msg =
            body['message'] ??
            (body['errors'] != null
                ? body['errors'].values.map((e) => e.join(', ')).join('\n')
                : 'Failed to update address');
        SnackbarHelper.showError(context, msg);
        return;
      }

      // ------------------- 3️⃣ Fetch Updated User -------------------
      final updatedUserRes = await http.get(
        Uri.parse(ApiEndpoints.userProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (updatedUserRes.statusCode == 200) {
        final updatedUser = UserModel.fromJson(
          jsonDecode(updatedUserRes.body)['data'],
          token: token,
        );
        Navigator.pop(context, updatedUser);
      } else {
        SnackbarHelper.showSuccess(context, 'Profile and address updated');
        Navigator.pop(context);
      }
    } catch (e) {
      SnackbarHelper.showError(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ---------- UI Helpers ----------
  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
    ),
  );

  Widget _glassCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _pillField(
    TextEditingController c,
    String label, {
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        style: const TextStyle(color: AppColors.textDark, fontSize: 16),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.inputFill,
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textGrey),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (val) => val!.trim().isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ✅ Fixed Bottom Button (color stays same while loading)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
            elevation: 6,
            shadowColor: AppColors.primary.withOpacity(0.4),
          ),
          // 🔑 keep button enabled so it doesn’t turn grey
          onPressed: _isSaving ? () {} : _saveProfile,
          child:
              _isSaving
                  ? const SizedBox(
                    height: 26,
                    width: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
        ),
      ),

      body: Stack(
        children: [
          // Gradient header
          Container(
            height: 230,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, Color(0xFFF96A86)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
          ),
          SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                children: [
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _glassCard([
                    _sectionTitle('👤  User Information'),
                    _pillField(_nameController, 'Full Name'),
                    _pillField(
                      _emailController,
                      'Email',
                      type: TextInputType.emailAddress,
                    ),
                  ]),
                  _glassCard([
                    _sectionTitle('🏠  Address Information'),
                    _pillField(_addressController, 'Address'),
                    _pillField(_cityController, 'City'),
                    _pillField(_stateController, 'State'),
                    _pillField(_countryController, 'Country'),
                    _pillField(
                      _postalController,
                      'Postal Code',
                      type: TextInputType.number,
                    ),
                  ]),
                  const SizedBox(height: 80), // spacing above bottom button
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
