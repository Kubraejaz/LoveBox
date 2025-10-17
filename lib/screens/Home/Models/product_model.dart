class ProductModel {
  final int id;
  final String name;
  final String? description;
  final String? sku;
  final String price;
  final int? stock;
  final int? minimumQty;
  final int? maximumQty;
  final String? categoryName;
  final String? subcategoryName;
  final String? brandName;
  final String? brandImage;
  final String? unitName;
  final String? businessName;
  final String? businessLogo;
  final String? businessAddress;
  final String? image;
  final String? barcode;
  final bool? isActive;

  bool isFavorite;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    this.sku,
    required this.price,
    this.stock,
    this.minimumQty,
    this.maximumQty,
    this.categoryName,
    this.subcategoryName,
    this.brandName,
    this.brandImage,
    this.unitName,
    this.businessName,
    this.businessLogo,
    this.businessAddress,
    this.image,
    this.barcode,
    this.isActive,
    this.isFavorite = false,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      sku: json['sku']?.toString(),
      price: json['price']?.toString() ?? '0',
      stock: _parseInt(json['stock']),
      minimumQty: _parseInt(json['minimum_qty']),
      maximumQty: _parseInt(json['maximum_qty']),
      categoryName: json['category_name']?.toString(),
      subcategoryName: json['subcategory_name']?.toString(),
      brandName: json['brand_name']?.toString(),
      brandImage: json['brand_image']?.toString(),
      unitName: json['unit_name']?.toString(),
      businessName: json['business_name']?.toString(),
      businessLogo: json['business_logo']?.toString(),
      businessAddress: json['business_address']?.toString(),
      image: json['image']?.toString(),
      barcode: json['barcode']?.toString(),
      isActive: json['is_active'] == null
          ? null
          : (json['is_active'] == true || json['is_active'].toString() == '1'),
      isFavorite: json['is_favorite'] == true,
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
      'minimum_qty': minimumQty,
      'maximum_qty': maximumQty,
      'category_name': categoryName,
      'subcategory_name': subcategoryName,
      'brand_name': brandName,
      'brand_image': brandImage,
      'unit_name': unitName,
      'business_name': businessName,
      'business_logo': businessLogo,
      'business_address': businessAddress,
      'image': image,
      'barcode': barcode,
      'is_active': isActive,
      'is_favorite': isFavorite,
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}