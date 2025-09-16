import 'package:flutter/material.dart';
import 'package:lovebox/constants/color.dart';
import 'package:lovebox/constants/strings.dart';
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

  Future<void> _loadCart() async {
    setState(() => _isLoading = true);

    final token = await LocalStorage.getAuthToken();
    if (token == null || token.isEmpty) {
      setState(() => _isLoading = false);
      // Show login dialog
      _showLoginDialog();
      return;
    }

    final cartData = await LocalStorage.getCart(token);

    setState(() {
      _isLoading = false;
      cartItems = cartData
          .map((e) => CartItem(
                id: e['productId'], // Use productId as CartItem id
                productId: e['productId'],
                quantity: e['quantity'],
              ))
          .toList();
    });
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('You need to login to view your cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ).then((_) {
                // Reload cart after login
                _loadCart();
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Login', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("My Cart", style: TextStyle(color: AppColors.primary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text("Your cart is empty", style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: cartItems.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          radius: 30,
                          child: Text('${item.productId}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        title: Text('Product ID: ${item.productId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text('Quantity: ${item.quantity}', style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w500)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                            final token = await LocalStorage.getAuthToken();
                            if (token != null) {
                              final cartData = await LocalStorage.getCart(token);
                              cartData.removeWhere((e) => e['productId'] == item.productId);
                              await LocalStorage.saveCart(token, cartData);
                              SnackbarHelper.showSuccess(context, "Item removed");
                              _loadCart();
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
