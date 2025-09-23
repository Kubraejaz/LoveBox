class ApiEndpoints {
  static const String baseUrl = 'http://10.108.72.19:8000/api/v1';

  // ---------- Auth ----------
  static const String login    = '$baseUrl/login';
  static const String register = '$baseUrl/register';

  // ---------- Products ----------
  static const String products = '$baseUrl/products';

  // ---------- Cart ----------
  static const String addToCart = '$baseUrl/cart/store';
  static const String viewCart  = '$baseUrl/cart/cart-item';

  // ---------- Wishlist ----------
  /// GET:    /wishlist               → fetch all wishlist items
  static const String wishlist = '$baseUrl/wishlist';

  /// POST:   /wishlist/store         → add a product to wishlist
  static const String addWishlist = '$baseUrl/wishlist/store';

  /// DELETE: /wishlist/delete/{id}   → remove a product from wishlist
  /// Usage:  '${ApiEndpoints.deleteWishlist}/$productId'
  static const String deleteWishlist = '$baseUrl/wishlist/delete';
}
