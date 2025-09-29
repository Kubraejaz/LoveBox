/// Central place for all API URLs
class ApiEndpoints {
  /// Base URL (already contains /user)
  static const String baseApi = 'http://192.168.100.227:8000/api/v1/user';

  // ---------- Auth ----------
  static const String login = '$baseApi/login';
  static const String register = '$baseApi/register';

  // ---------- Products ----------
  static const String products = '$baseApi/products';

  // ---------- Cart ----------
  static const String addToCart = '$baseApi/cart/store';
  static const String viewCart = '$baseApi/cart/cart-item';

  // ---------- Wishlist ----------
  static const String wishlist = '$baseApi/wishlist';
  static const String addWishlist = '$baseApi/wishlist/store';
  static const String deleteWishlist = '$baseApi/wishlist/delete';

  // ---------- Banners ----------
  static const String banners = '$baseApi/banners';

  // ---------- Address Types ----------
  static const String addressTypes = '$baseApi/address-types';

  // ---------- User/Profile ----------
  static const String userProfile   = '$baseApi/profile';          // GET profile
  static const String updateProfile = '$baseApi/profile/update';   // PUT profile
  static const String fetchAddresses = '$baseApi/addresses';       // GET all addresses
  static const String updateAddress  = '$baseApi/addresses/update'; // PUT address (id optional)
}
