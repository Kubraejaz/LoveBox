import 'package:flutter/material.dart';
import 'package:lovebox/utils/snackbar_helper.dart';
import 'product_detail_screen.dart';
import '../constants/color.dart';
import '../constants/strings.dart';
import '../services/product_service.dart';
import '../models/product_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<ProductModel>> _productsFuture;
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  // ✅ Categories (dynamic now)
  List<String> categories = ["All"];
  String selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ✅ Setup scroll listener
  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 50 &&
          !_isRefreshing) {
        _refreshProducts();
      }
    });
  }

  // ✅ Load products & extract categories dynamically
  Future<List<ProductModel>> _loadProducts() async {
    final products = await ProductService().getProducts();

    // Extract unique categories from products
    final uniqueCategories = <String>{};
    for (var product in products) {
      if (product.category?.name != null && product.category!.name.isNotEmpty) {
        uniqueCategories.add(product.category!.name);
      }
    }

    setState(() {
      categories = ["All", ...uniqueCategories.toList()];
    });

    return products;
  }

  // ✅ Refresh products function
  Future<void> _refreshProducts() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      SnackbarHelper.showInfo(context, "Refreshing products...");

      setState(() {
        _productsFuture = _loadProducts();
      });

      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      SnackbarHelper.showError(context, "Failed to refresh: $e");
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  // ✅ Pull to refresh
  Future<void> _onRefresh() async {
    await _refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.appName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Dynamic Categories
              Container(
                height: 40,
                alignment: Alignment.centerLeft,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category == selectedCategory;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.primary
                                  : AppColors.textGrey,
                          borderRadius: BorderRadius.circular(20),
                          border:
                              !isSelected
                                  ? Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  )
                                  : null,
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // ✅ Search Bar
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: AppStrings.searchHint,
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ✅ Product Grid
              Expanded(
                child: FutureBuilder<List<ProductModel>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Error: ${snapshot.error}",
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "No products available",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // ✅ Filter by category
                    final products =
                        selectedCategory == "All"
                            ? snapshot.data!
                            : snapshot.data!
                                .where(
                                  (p) => p.category?.name == selectedCategory,
                                )
                                .toList();

                    return GridView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: products.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        ProductDetailScreen(product: product),
                              ),
                            );
                          },
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
                                // ✅ Product Image
                                Expanded(
                                  flex: 3,
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(16),
                                            ),
                                        child: Image.network(
                                          product.image ??
                                              "https://via.placeholder.com/150",
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              color: Colors.grey[200],
                                              child: const Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.broken_image,
                                                    size: 40,
                                                    color: Colors.grey,
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    "Image not available",
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                                      // ✅ Heart Icon
                                      Positioned(
                                        top: 9,
                                        right: 7,
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.1,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            iconSize: 18,
                                            icon: const Icon(
                                              Icons.favorite_border,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              SnackbarHelper.showSuccess(
                                                context,
                                                "${product.name} added to favorites",
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // ✅ Product Info
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                            color: AppColors.primary,
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
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
