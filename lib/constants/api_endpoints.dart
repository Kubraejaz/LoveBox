class ApiEndpoints {
  static const String baseUrl = 'http://192.168.100.227:8000/api/v1';

  // ---------- Auth ----------
  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/register';

  // ---------- Products ----------
  static const String products = '$baseUrl/products';

  // ---------- Cart ----------
  static const String addToCart = '$baseUrl/cart/store';
  static const String viewCart = '$baseUrl/cart/cart-item';

  // ---------- Wishlist ----------
  static const String wishlist = '$baseUrl/wishlist';
  static const String addWishlist = '$baseUrl/wishlist/store';
  static const String deleteWishlist = '$baseUrl/wishlist/delete';

  // ---------- Banners ----------
  /// GET: /banners → fetch all banners
  static const String banners = '$baseUrl/banners';
}
