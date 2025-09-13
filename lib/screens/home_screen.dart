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
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

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

  // Scroll listener for infinite scroll refresh
  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 50 &&
          !_isRefreshing) {
        _refreshBackendData();
      }
    });
  }

  // Load products & extract categories
  Future<List<ProductModel>> _loadProducts() async {
    final products = await ProductService().getProducts();

    // Extract categories dynamically
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

  // Backend-only refresh
  Future<void> _refreshBackendData() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      // Reload products from backend
      _productsFuture = _loadProducts();
      await _productsFuture;
      await Future.delayed(
        const Duration(milliseconds: 300),
      ); // Optional smooth delay
    } catch (e) {
      debugPrint("Backend refresh failed: $e");
    }

    setState(() {
      _isRefreshing = false;
    });
  }

  // Pull-to-refresh triggers backend refresh
  Future<void> _onRefresh() async {
    await _refreshBackendData();
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
              const SearchSection(),
              const SizedBox(height: 20),

              // Ad Banner
              const AdBannerSection(),
              const SizedBox(height: 24),

              // Product Grid
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

                    // Filter by category
                    final products =
                        selectedCategory == "All"
                            ? snapshot.data!
                            : snapshot.data!
                                .where(
                                  (p) => p.category?.name == selectedCategory,
                                )
                                .toList();

                    return ProductGridSection(
                      products: products,
                      scrollController: _scrollController,
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
