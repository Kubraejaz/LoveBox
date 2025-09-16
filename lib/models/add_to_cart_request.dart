class AddToCartRequest {
  final int productId;
  final int quantity;

  AddToCartRequest({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {'product_id': productId, 'quantity': quantity};
  }
}
