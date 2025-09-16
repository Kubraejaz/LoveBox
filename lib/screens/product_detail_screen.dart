import 'package:flutter/material.dart';
import 'package:lovebox/constants/color.dart';
import 'package:lovebox/constants/strings.dart';
import 'package:lovebox/utils/snackbar_helper.dart';
import '../models/product_model.dart';
import '../services/local_storage.dart';
import '../screens/login_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isAdding = false;
  int _quantity = 1;

  /// ✅ Prompt user to login if no token
  void _showLoginDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Login Required'),
            content: const Text('Please login to add items to your cart.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
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

  /// ✅ Add to cart after checking only the saved auth token
  Future<void> _addToCart() async {
    final token = await LocalStorage.getAuthToken();
    if (token == null || token.isEmpty) {
      _showLoginDialog();
      return;
    }

    if (_quantity <= 0) {
      SnackbarHelper.showError(context, "Quantity must be at least 1");
      return;
    }

    setState(() => _isAdding = true);

    try {
      // cart is stored per-user (token acts as user key)
      final cart = await LocalStorage.getCart(token);
      final index = cart.indexWhere(
        (item) => item['productId'] == widget.product.id,
      );

      if (index >= 0) {
        cart[index]['quantity'] += _quantity;
      } else {
        cart.add({
          'productId': widget.product.id,
          'name': widget.product.name,
          'price': widget.product.price,
          'image': widget.product.image ?? '',
          'quantity': _quantity,
        });
      }

      await LocalStorage.saveCart(token, cart);
      SnackbarHelper.showSuccess(context, "Item added to cart");
    } catch (e) {
      SnackbarHelper.showError(context, "Error adding item: $e");
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final imageUrl =
        (p.image != null && p.image!.isNotEmpty)
            ? p.image!
            : 'https://via.placeholder.com/600x300?text=No+Image';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          p.name,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: Image.network(
                imageUrl,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      height: 300,
                      color: AppColors.brokenImage,
                      child: const Icon(
                        Icons.broken_image,
                        size: 80,
                        color: AppColors.textGrey,
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 20),

            // Name + Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Text(
                    "PKR ${p.price}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stock
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Stock: ${p.stock ?? 'N/A'}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Rating
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    "${p.ratingAvg ?? 0} / 5",
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "(${p.ratingCount ?? 0} reviews)",
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quantity Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    "Quantity:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.remove,
                            color: AppColors.primary,
                          ),
                          onPressed:
                              _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: AppColors.primary),
                          onPressed:
                              (p.stock == null || _quantity < p.stock!)
                                  ? () => setState(() => _quantity++)
                                  : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                p.description ?? AppStrings.defaultProductDescription,
                style: const TextStyle(fontSize: 15, color: AppColors.textGrey),
              ),
            ),
            const SizedBox(height: 20),

            // Add to Cart Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: _isAdding ? null : _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isAdding
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          AppStrings.addToCart,
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
