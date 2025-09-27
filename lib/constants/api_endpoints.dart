class ApiEndpoints {
  /// 🔑 Base URL (must include `/user` as per your requirement)
  static const String baseUrl = 'http://192.168.18.33:8000/api/v1/user';

  // ---------- Auth ----------
  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/register';

  // ---------- Products ----------
  // If your API expects /user/products
  static const String products = '$baseUrl/products';

  // ---------- Cart ----------
  static const String addToCart = '$baseUrl/cart/store';
  static const String viewCart = '$baseUrl/cart/cart-item';

  // ---------- Wishlist ----------
  static const String wishlist = '$baseUrl/wishlist';
  static const String addWishlist = '$baseUrl/wishlist/store';
  static const String deleteWishlist = '$baseUrl/wishlist/delete';

  // ---------- Banners ----------
  static const String banners = '$baseUrl/banners';

  // ---------- Address Types ----------
  static const String addressTypes = '$baseUrl/address-types';

  // ---------- User/Profile ----------
  /// ✅ Important: remove the extra '/user' to avoid /user/user/profile
  static const String userProfile = '$baseUrl/profile';
}
