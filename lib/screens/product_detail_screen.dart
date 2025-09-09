import 'package:flutter/material.dart';
import 'package:lovebox/constants/color.dart';
import 'package:lovebox/constants/strings.dart';
import 'package:lovebox/utils/snackbar_helper.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          product["name"],
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
      body: SingleChildScrollView(
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
                product["image"],
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

            // Product Name & Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product["name"],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Text(
                    product["price"],
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

            // Product Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                product["description"] ?? AppStrings.defaultProductDescription,
                style: const TextStyle(fontSize: 15, color: AppColors.textGrey),
              ),
            ),

            const SizedBox(height: 20),

            // Add to Cart Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () {
                  SnackbarHelper.showSuccess(
                    context,
                    "${product["name"]}${AppStrings.productAddedToCart}",
                  );
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
    );
  }
}
