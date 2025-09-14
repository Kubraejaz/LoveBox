import 'package:flutter/material.dart';
import 'package:lovebox/sections/category_section.dart';
import 'package:lovebox/sections/product_grid_section.dart';
import 'package:lovebox/sections/search_section.dart';
import 'package:lovebox/sections/ad_banner_section.dart';
import '../constants/color.dart';
import '../constants/strings.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<ProductModel>> _productsFuture;

  List<String> categories = ["All"];
  String selectedCategory = "All";
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Simple method to reload all products
  Future<List<ProductModel>> _loadProducts() async {
    final products = await ProductService().getProducts();

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

  // Pull-to-refresh that refreshes EVERYTHING - backend data + UI
  Future<void> _onRefresh() async {
    // Reset all UI state first
    setState(() {
      selectedCategory = "All"; // Reset category selection
      _searchQuery = ""; // Clear search query
      categories = ["All"]; // Reset categories to default
    });

    // Then reload backend data which will also update UI
    setState(() {
      _productsFuture = _loadProducts();
    });

    // Wait for the data to load
    await _productsFuture;

    // Force a complete UI rebuild
    if (mounted) {
      setState(() {
        // This ensures everything is refreshed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
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
        child: FutureBuilder<List<ProductModel>>(
          future: _productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
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
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            // Apply filters
            var products = snapshot.data!;

            if (selectedCategory != "All") {
              products =
                  products
                      .where((p) => p.category?.name == selectedCategory)
                      .toList();
            }

            final query = _searchQuery.trim();
            if (query.isNotEmpty) {
              products =
                  products.where((p) {
                    final name = (p.name ?? '').toLowerCase();
                    final desc = (p.description ?? '').toLowerCase();
                    return name.contains(query) || desc.contains(query);
                  }).toList();
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories
                  CategorySection(
                    categories: categories,
                    selectedCategory: selectedCategory,
                    onCategorySelected: (category) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Search
                  SearchSection(
                    onSearchChanged: (query) {
                      setState(() {
                        _searchQuery = query.toLowerCase();
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Ad Banner
                  const AdBannerSection(),
                  const SizedBox(height: 24),

                  // Show message if no results
                  if (products.isEmpty)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "No matching products found",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    // Use the separated ProductGridSection component
                    ProductGridSection(
                      products: products,
                      scrollController:
                          ScrollController(), // Dummy controller since we don't use infinite scroll
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
