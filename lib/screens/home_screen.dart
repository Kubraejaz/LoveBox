import 'package:flutter/material.dart';
import 'package:lovebox/sections/category_section.dart';
import 'package:lovebox/sections/product_grid_section.dart';
import 'package:lovebox/sections/search_section.dart';
import 'package:lovebox/sections/banner_section.dart';
import '../constants/color.dart';
import '../constants/strings.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/local_storage.dart'; // ✅ Import LocalStorage

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
    _restoreFilters(); // ✅ Load saved filters from local storage
  }

  // Load last saved category & search query
  Future<void> _restoreFilters() async {
    final savedCategory =
        await LocalStorage.getNavIndex(); // reuse or create new keys
    final savedSearch =
        await LocalStorage.getUser(); // 👈 you may want a new method for search

    // Better: define new methods for these in LocalStorage
    final prefsCategory = await LocalStorage.getString("lastCategory");
    final prefsSearch = await LocalStorage.getString("lastSearch");

    if (prefsCategory != null && prefsCategory.isNotEmpty) {
      setState(() => selectedCategory = prefsCategory);
    }
    if (prefsSearch != null && prefsSearch.isNotEmpty) {
      setState(() => _searchQuery = prefsSearch);
    }
  }

  // Save filters
  Future<void> _saveFilters() async {
    await LocalStorage.setString("lastCategory", selectedCategory);
    await LocalStorage.setString("lastSearch", _searchQuery);
  }

  // Load products and extract categories
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

  // Pull-to-refresh: reload products without resetting category or search
  Future<void> _onRefresh() async {
    setState(() {
      _productsFuture = _loadProducts();
    });

    await _productsFuture;

    if (mounted) {
      setState(() {});
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
            if (snapshot.connectionState == ConnectionState.waiting &&
                snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (snapshot.hasError) {
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
            }

            var products = snapshot.data ?? [];

            // Category filter
            if (selectedCategory != "All") {
              products =
                  products
                      .where((p) => p.category?.name == selectedCategory)
                      .toList();
            }

            // Search filter
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
                        if (category != "All") _searchQuery = "";
                      });
                      _saveFilters(); // ✅ Save selected category
                    },
                  ),
                  const SizedBox(height: 20),

                  // Show Search + Banner only if "All" is selected
                  if (selectedCategory == "All") ...[
                    SearchSection(
                      onSearchChanged: (query) {
                        setState(() {
                          _searchQuery = query.toLowerCase();
                        });
                        _saveFilters(); // ✅ Save search query
                      },
                    ),
                    const SizedBox(height: 20),
                    const BannerSection(),
                    const SizedBox(height: 24),
                  ],

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
                    SizedBox(
                      height:
                          selectedCategory == "All"
                              ? null
                              : MediaQuery.of(context).size.height * 0.7,
                      child: ProductGridSection(
                        products: products,
                        scrollController: ScrollController(),
                      ),
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
