import 'package:flutter/material.dart';
import 'package:lovebox/constants/color.dart';
import 'package:lovebox/providers/whishlist_provider.dart';
import 'package:lovebox/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:lovebox/models/product_model.dart';
import 'package:lovebox/services/local_storage.dart';
import 'package:lovebox/utils/snackbar_helper.dart';
import 'package:lovebox/constants/network_storage.dart';

class ProductGridSection extends StatelessWidget {
  final List<ProductModel> products;
  final ScrollController scrollController;

  const ProductGridSection({
    super.key,
    required this.products,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    return GridView.builder(
      controller: scrollController,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        final imageUrl = NetworkStorage.getUrl(product.image);

        return InkWell(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(product: product),
                ),
              ),
          borderRadius: BorderRadius.circular(20),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
            shadowColor: Colors.black12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child:
                            imageUrl.isNotEmpty
                                ? Image.network(
                                  imageUrl,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => _imageErrorWidget(),
                                )
                                : _imageErrorWidget(),
                      ),
                      // Wishlist button
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 20,
                            icon: Icon(
                              wishlistProvider.isInWishlist(product.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: AppColors.primary,
                            ),
                            onPressed: () async {
                              final token = await LocalStorage.getAuthToken();
                              if (token == null || token.isEmpty) {
                                SnackbarHelper.showError(
                                  context,
                                  "Please login first",
                                );
                                return;
                              }

                              try {
                                if (wishlistProvider.isInWishlist(product.id)) {
                                  await wishlistProvider.removeFromWishlist(
                                    product,
                                  );
                                  SnackbarHelper.showSuccess(
                                    context,
                                    "${product.name} removed from wishlist",
                                  );
                                } else {
                                  await wishlistProvider.addToWishlist(product);
                                  SnackbarHelper.showSuccess(
                                    context,
                                    "${product.name} added to wishlist",
                                  );
                                }
                              } catch (_) {
                                SnackbarHelper.showError(
                                  context,
                                  "Failed to update wishlist",
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      // Optional: Price badge
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.pinkAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "PKR ${product.price}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.description ?? "",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _imageErrorWidget() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 40, color: Colors.grey),
          SizedBox(height: 4),
          Text(
            "Image not available",
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
