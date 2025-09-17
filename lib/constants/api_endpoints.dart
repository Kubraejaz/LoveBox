class ApiEndpoints {
  static const String baseUrl = 'http://10.108.72.63:8000/api/v1';
  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/register';
  static const String products = '$baseUrl/products';

  // Cart endpoints
  static const String addToCart = '$baseUrl/cart/store';
  static const String viewCart = '$baseUrl/cart/cart-item';
}
