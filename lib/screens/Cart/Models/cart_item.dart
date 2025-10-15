class CartItem {
  final int id;
  final int productId;
  final String productName;
  final String productImage;
  final int quantity;
  final int stock;
  final double price;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.stock,
    required this.price,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>? ?? {};

    return CartItem(
      id: _parseInt(json['id']) ?? 0,
      productId: _parseInt(json['product_id']) ?? 0,
      productName: product['name']?.toString() ?? '',
      productImage: product['image']?.toString() ?? '',
      quantity: _parseInt(json['quantity']) ?? 0,
      stock: _parseInt(product['stock']) ?? 0,
      price: _parseDouble(product['price']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'quantity': quantity,
      'product': {
        'name': productName,
        'image': productImage,
        'stock': stock,
        'price': price,
      },
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double _parseDouble(dynamic value) {
    try {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
    } catch (_) {}
    return 0.0; // fallback
  }
}
