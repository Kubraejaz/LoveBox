import 'package:flutter/material.dart';
import '../Models/cart_item.dart';
import '../Services/cart_service.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];
  bool _isLoading = false;

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchCartItems() async {
    try {
      setLoading(true);
      _cartItems = await CartService.fetchCart();
    } catch (e) {
      debugPrint('Error fetching cart: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> removeItem(int cartId) async {
    try {
      setLoading(true);
      final success = await CartService.removeItem(cartId);
      if (success) {
        _cartItems.removeWhere((item) => item.id == cartId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error removing item: $e');
    } finally {
      setLoading(false);
    }
  }

  // ✅ Add this method
  Future<void> addToCart(dynamic product, int quantity) async {
    try {
      setLoading(true);
      final success = await CartService.addToCart(product.id, quantity);
      if (success) {
        await fetchCartItems();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');
    } finally {
      setLoading(false);
    }
  }
}
