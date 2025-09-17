import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lovebox/constants/api_endpoints.dart';
import 'package:lovebox/constants/color.dart';
import 'package:lovebox/models/cart_item.dart';
import 'package:lovebox/services/local_storage.dart';
import 'package:lovebox/utils/snackbar_helper.dart';
import 'login_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  /// 🔵 Load cart items from Laravel API
  Future<void> _loadCart() async {
    setState(() => _isLoading = true);

    final token = await LocalStorage.getAuthToken();
    if (token == null || token.isEmpty) {
      setState(() => _isLoading = false);
      _showLoginDialog();
      return;
    }

    try {
      final url = Uri.parse(ApiEndpoints.viewCart);
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('🔵 ViewCart Status: ${response.statusCode}');
      print('🔵 ViewCart Body:   ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> rawList = jsonDecode(response.body);

        setState(() {
          cartItems =
              rawList
                  .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
                  .toList();
          _isLoading = false;
        });
      } else {
        SnackbarHelper.showError(
          context,
          'Failed to load cart. Status: ${response.statusCode}',
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('❌ Error loading cart: $e');
      SnackbarHelper.showError(context, 'Error loading cart: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Login Required'),
            content: const Text('You need to login to view your cart.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ).then((_) => _loadCart());
                },
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _removeItem(CartItem item) async {
    final token = await LocalStorage.getAuthToken();
    if (token == null) return;

    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('${ApiEndpoints.baseUrl}/cart/${item.id}');
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        SnackbarHelper.showSuccess(context, "Item removed");
        _loadCart();
      } else {
        SnackbarHelper.showError(
          context,
          "Failed to remove item. Status: ${response.statusCode}",
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      SnackbarHelper.showError(context, "Error removing item: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "My Cart",
          style: TextStyle(color: AppColors.primary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary, // ✅ pinkish spinner
                ),
              )
              : cartItems.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Your cart is empty",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: cartItems.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        radius: 30,
                        child: Text(
                          '${item.productId}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        'Product ID: ${item.productId}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Quantity: ${item.quantity}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _removeItem(item),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
