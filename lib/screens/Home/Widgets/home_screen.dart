import 'package:flutter/material.dart';
import 'package:lovebox/screens/Home/Widgets/category_section.dart';
import 'package:lovebox/screens/Home/Widgets/product_grid_section.dart';
import 'package:lovebox/screens/Home/Widgets/search_section.dart';
import 'package:lovebox/screens/Home/Widgets/banner_section.dart';
import '../../../constants/color.dart';
import '../../../constants/strings.dart';
import '../Models/product_model.dart';
import '../Services/product_service.dart';
import '../../Core/local_storage.dart'; // ✅ Import LocalStorage

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
    final prefsCategory = await LocalStorage.getString("lastCategory");
    final prefsSearch = await LocalStorage.getString("lastSearch");

    if (mounted) {
      setState(() {
        if (prefsCategory != null && prefsCategory.isNotEmpty) {
          selectedCategory = prefsCategory;
        }
        if (prefsSearch != null && prefsSearch.isNotEmpty) {
          _searchQuery = prefsSearch;
        }
      });
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
      final catName = product.categoryName;
      if (catName != null && catName.isNotEmpty) {
        uniqueCategories.add(catName);
      }
    }

    if (mounted) {
      setState(() {
        categories = ["All", ...uniqueCategories.toList()];
        if (!categories.contains(selectedCategory)) {
          selectedCategory = "All";
        }
      });
    }

    return products;
  }

  // Pull-to-refresh: reload products without resetting category or search
  Future<void> _onRefresh() async {
    setState(() {
      _productsFuture = _loadProducts();
    });

    await _productsFuture;

    await _saveFilters();
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
                      .where((p) => p.categoryName == selectedCategory)
                      .toList();
            }

            // Search filter
            final query = _searchQuery.trim().toLowerCase();
            if (query.isNotEmpty) {
              products =
                  products.where((p) {
                    final name = (p.name).toLowerCase();
                    final desc = (p.description ?? '').toLowerCase();
                    final brand = (p.brandName ?? '').toLowerCase();
                    return name.contains(query) ||
                        desc.contains(query) ||
                        brand.contains(query);
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
                      _saveFilters();
                    },
                  ),
                  const SizedBox(height: 12), // Reduced spacing
                  // Search + Banner only if "All"
                  if (selectedCategory == "All") ...[
                    SearchSection(
                      onSearchChanged: (query) {
                        setState(() {
                          _searchQuery = query;
                        });
                        _saveFilters();
                      },
                    ),
                    const SizedBox(height: 12), // Reduced spacing
                    const BannerSection(),
                    const SizedBox(height: 16), // Reduced spacing
                  ],

                  // Product Grid or Empty State
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
                    ProductGridSection(
                      products: products,
                      scrollController: ScrollController(),
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
