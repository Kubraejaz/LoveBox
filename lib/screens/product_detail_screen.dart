import 'package:flutter/material.dart';
import 'package:lovebox/constants/color.dart';
import 'package:lovebox/constants/strings.dart';
import 'package:lovebox/sections/refresh_helper.dart';
import 'package:lovebox/utils/snackbar_helper.dart';
import 'package:lovebox/services/cart_service.dart';
import '../models/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final cartService = CartService();

  String _formatPrice(String price) {
    // Simple formatting hook — you can replace with NumberFormat later
    return price;
  }

  Future<void> _refreshProduct() async {
    await RefreshHelper.refreshProducts(
      context: context,
      refreshFunction: () async {
        setState(() {
          // Just reset state to simulate refresh (no API call here)
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    final imageUrl =
        (product.image != null && product.image!.isNotEmpty)
            ? product.image!
            : 'https://via.placeholder.com/600x300?text=No+Image';

    final ratingText = "${(product.ratingAvg ?? 0).toString()} / 5";
    final ratingCountText = "(${product.ratingCount ?? 0} reviews)";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          product.name,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        elevation: 0,
        titleSpacing: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProduct,
        color: AppColors.primary,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 300,
                      color: AppColors.brokenImage,
                      child: const Icon(
                        Icons.broken_image,
                        size: 80,
                        color: AppColors.textGrey,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Name & Price (PKR)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Text(
                      "PKR ${_formatPrice(product.price)}",
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
                  "Stock: ${product.stock?.toString() ?? 'N/A'}",
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
                    const SizedBox(width: 8),
                    Text(
                      ratingText,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ratingCountText,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textGrey,
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
                  product.description ?? AppStrings.defaultProductDescription,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textGrey,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Add to Cart Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () async {
                    final productMap = product.toJson();
                    final added = await cartService.addItem(productMap);

                    if (added) {
                      SnackbarHelper.showSuccess(
                        context,
                        "${product.name}${AppStrings.productAddedToCart}",
                      );
                    } else {
                      SnackbarHelper.showError(
                        context,
                        "${product.name} is already in the cart!",
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    AppStrings.addToCart,
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
