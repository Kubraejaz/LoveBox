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
  bool _loadingAddress = true;
  AddressModel? _defaultAddress;
  List<AddressModel> _userAddresses = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _loadingAddress = true);
    try {
      final token = widget.user.token;
      final addresses = await AddressService.fetchUserAddresses(token);

      _userAddresses = addresses;

      _defaultAddress =
          addresses.isNotEmpty
              ? addresses.firstWhere(
                (a) => a.isDefault,
                orElse: () => addresses.first,
              )
              : null;

      if (_defaultAddress != null) {
        _addressController.text = _defaultAddress!.address;
        _cityController.text = _defaultAddress!.city;
        _stateController.text = _defaultAddress!.state;
        _countryController.text = _defaultAddress!.country;
        _postalController.text = _defaultAddress!.postalCode;
      }
    } catch (e) {
      debugPrint('Error fetching addresses: $e');
      if (mounted)
        SnackbarHelper.showError(context, 'Failed to load addresses');
    } finally {
      if (mounted) setState(() => _loadingAddress = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final token = widget.user.token;
      final url = Uri.parse(ApiEndpoints.userProfile);

      final body = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'country': _countryController.text.trim(),
        'postal_code': _postalController.text.trim(),
      };

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final updatedAddresses =
            _defaultAddress != null
                ? [
                  _defaultAddress!.copyWith(
                    address: _addressController.text.trim(),
                    city: _cityController.text.trim(),
                    state: _stateController.text.trim(),
                    country: _countryController.text.trim(),
                    postalCode: _postalController.text.trim(),
                  ),
                ]
                : <AddressModel>[];

        final updatedUser = widget.user.copyWith(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          addresses: updatedAddresses,
        );

        await LocalStorage.saveUser(updatedUser);

        if (!mounted) return;

        // ✅ Show success snackbar
        SnackbarHelper.showSuccess(context, 'Profile updated successfully');
        Navigator.pop(context, updatedUser);
      } else {
        throw Exception(
          'Update failed: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      if (mounted) SnackbarHelper.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _decoration([String? label]) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 1,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          _loadingAddress
              ? Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'User Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameController,
                        decoration: _decoration('Full Name'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        decoration: _decoration('Email'),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Address Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        decoration: _decoration('Address'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _cityController,
                        decoration: _decoration('City'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _stateController,
                        decoration: _decoration('State'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _countryController,
                        decoration: _decoration('Country'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _postalController,
                        decoration: _decoration('Postal Code'),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isSaving ? () {} : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              disabledBackgroundColor: AppColors.primary,
                              disabledForegroundColor: Colors.white,
                            ),
                            child:
                                _isSaving
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
      backgroundColor: AppColors.background,
    );
  }
}
