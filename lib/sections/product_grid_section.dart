import 'package:flutter/material.dart';
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
        childAspectRatio: 0.75,
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
          borderRadius: BorderRadius.circular(16),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            shadowColor: Colors.black26,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
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
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 32,
                          height: 32,
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
                            iconSize: 18,
                            icon: Icon(
                              wishlistProvider.isInWishlist(product.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
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
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        const SizedBox(height: 8),
                        Text(
                          "PKR ${product.price}",
                          style: const TextStyle(
                            color: Colors.pink,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
