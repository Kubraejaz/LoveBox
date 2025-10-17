import 'package:flutter/material.dart';
import '../Models/cart_item.dart';
import '../Services/cart_service.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];
  bool _isLoading = false;

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Fetch cart items
  Future<void> fetchCartItems() async {
    try {
      _setLoading(true);
      _cartItems = await CartService.fetchCart();
    } catch (e) {
      debugPrint('❌ Error fetching cart: $e');
      // Keep old cart items on failure
    } finally {
      _setLoading(false);
    }
  }

  /// Add item to cart
  /// Returns the service response map so UI can show snackbars based on backend message.
  Future<Map<String, dynamic>> addToCart(dynamic product, int quantity) async {
    _setLoading(true);
    try {
      final response = await CartService.addToCart(product.id, quantity);

      // On success refresh cart items (best effort)
      if (response['success'] == true) {
        await fetchCartItems();
      }

      return response;
    } catch (e) {
      debugPrint('❌ Error in addToCart: $e');
      // Re-throw UnauthorizedException so UI can show login dialog.
      if (e is UnauthorizedException) rethrow;
      // Return a failure response for general exceptions
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.',
      };
    } finally {
      _setLoading(false);
    }
  }

  /// Remove cart item locally after successful deletion on server
  Future<bool> removeItem(int cartId) async {
    _setLoading(true);
    try {
      final success = await CartService.removeItem(cartId);
      if (success) {
        _cartItems.removeWhere((item) => item.id == cartId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('❌ Error removing item: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
