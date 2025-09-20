class CartItem {
  final int id;
  final int productId;
  final String productName;
  final String productImage;
  final int quantity;
  final int stock;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.stock,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] ?? {};
    return CartItem(
      id: _parseInt(json['id']) ?? 0,
      productId: _parseInt(json['product_id']) ?? 0,
      productName: product['name'] ?? '',
      productImage: product['image'] ?? '',
      quantity: _parseInt(json['quantity']) ?? 0,
      stock: _parseInt(product['stock']) ?? 0,
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
      },
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
