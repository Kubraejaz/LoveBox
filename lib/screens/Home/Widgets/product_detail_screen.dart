import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lovebox/screens/Core/local_storage.dart';
import 'package:provider/provider.dart';
import '../Models/product_model.dart';
import '../../Wishlist/Providers/whishlist_provider.dart';
import '../../../constants/color.dart';
import '../../../constants/network_storage.dart';
import '../../../utils/snackbar_helper.dart';
import '../../Authentication/Widgets/login_screen.dart';
import '../../../constants/api_endpoints.dart';
import 'package:http/http.dart' as http;

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isAdding = false;
  int _quantity = 1;

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to add items to your cart or wishlist.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('Login', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

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
      final response = await http.post(
        Uri.parse(ApiEndpoints.addToCart),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'product_id': widget.product.id,
          'quantity': _quantity,
        }),
      );

      Map<String, dynamic>? data;
      try {
        final trimmed = response.body.trim();
        if (trimmed.isNotEmpty &&
            (trimmed.startsWith('{') || trimmed.startsWith('['))) {
          data = jsonDecode(trimmed);
        }
      } catch (_) {}

      if (response.statusCode == 201 || response.statusCode == 200) {
        SnackbarHelper.showSuccess(
          context,
          data?['message'] ?? "Item added to cart!",
        );
      } else if (response.statusCode == 422) {
        SnackbarHelper.showError(
          context,
          data?['error'] ?? "Item is already in your cart.",
        );
      } else {
        SnackbarHelper.showError(
          context,
          data?['message'] ?? "Unexpected error (status ${response.statusCode})",
        );
      }
    } catch (e) {
      SnackbarHelper.showError(context, "Error adding item: $e");
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final imageUrl = NetworkStorage.getUrl(p.image);

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
        actions: [
          IconButton(
            icon: Icon(
              wishlistProvider.isInWishlist(p.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: () async {
              final token = await LocalStorage.getAuthToken();
              if (token == null || token.isEmpty) {
                _showLoginDialog();
                return;
              }

              try {
                if (wishlistProvider.isInWishlist(p.id)) {
                  await wishlistProvider.removeFromWishlist(p);
                  SnackbarHelper.showSuccess(
                      context, "${p.name} removed from wishlist");
                } else {
                  await wishlistProvider.addToWishlist(p);
                  SnackbarHelper.showSuccess(
                      context, "${p.name} added to wishlist");
                }
              } catch (e) {
                SnackbarHelper.showError(context, e.toString());
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Product Image
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 250,
                    color: AppColors.brokenImage,
                    child: const Icon(
                      Icons.broken_image,
                      size: 80,
                      color: AppColors.textGrey,
                    ),
                  ),
                ),
              ),
            ),

            // Name & Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.8),
                          AppColors.primary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "PKR ${p.price}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            // Stock & Rating
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(child: _infoCard("Stock", "${p.stock ?? 'N/A'}")),
                  const SizedBox(width: 16),
                  Expanded(child: _ratingCard("${p.ratingAvg ?? 0} / 5")),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quantity Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
                  const SizedBox(width: 12),
                  _quantitySelector(p),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  p.description ?? "No description available.",
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Add to Cart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: _isAdding ? null : _addToCart,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(AppColors.primary),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  minimumSize: MaterialStateProperty.all(
                    const Size(double.infinity, 55),
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  elevation: MaterialStateProperty.all(6),
                ),
                child: _isAdding
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        "Add to Cart",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textGrey)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _ratingCard(String rating) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Rating",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textGrey),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                rating,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quantitySelector(ProductModel p) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: AppColors.primary),
            onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$_quantity',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: (p.stock == null || _quantity < p.stock!)
                ? () => setState(() => _quantity++)
                : null,
          ),
        ],
      ),
    );
  }
}
