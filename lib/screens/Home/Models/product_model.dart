class ProductModel {
  final int id;
  final String name;
  final String? description;
  final String? sku;
  final String price;
  final int? stock;
  final int? categoryId;
  final double? ratingAvg;
  final int? ratingCount;
  final String? image;
  final bool? isActive;
  final Category? category;

  bool isFavorite; // 🔹 added

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    this.sku,
    required this.price,
    this.stock,
    this.categoryId,
    this.ratingAvg,
    this.ratingCount,
    this.image,
    this.isActive,
    this.category,
    this.isFavorite = false, // default false
  });

  double? get rating => ratingAvg;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      sku: json['sku']?.toString(),
      price: json['price']?.toString() ?? '0',
      stock: _parseInt(json['stock']),
      categoryId: _parseInt(json['category_id']),
      ratingAvg: json['rating_avg'] != null
          ? double.tryParse(json['rating_avg'].toString())
          : null,
      ratingCount: _parseInt(json['rating_count']),
      image: json['image']?.toString(),
      isActive: json['is_active'] == null
          ? null
          : (json['is_active'] == true || json['is_active'].toString() == '1'),
      category: json['category'] != null
          ? Category.fromJson(Map<String, dynamic>.from(json['category']))
          : null,
      isFavorite: json['is_favorite'] == true, // 🔹 set from API if available
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sku': sku,
      'price': price,
      'stock': stock,
      'category_id': categoryId,
      'rating_avg': ratingAvg,
      'rating_count': ratingCount,
      'image': image,
      'is_active': isActive,
      'category': category?.toJson(),
      'is_favorite': isFavorite,
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: ProductModel._parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
