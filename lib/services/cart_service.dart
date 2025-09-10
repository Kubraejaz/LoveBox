import 'package:lovebox/services/local_storage.dart';

class CartService {
  // ✅ Singleton instance
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  List<Map<String, dynamic>> _cartItems = [];
  String? _userId;

  // ✅ Load cart for the currently logged-in user
  Future<void> loadCart() async {
    final user = await LocalStorage.getUser();
    _userId = user['id'];

    if (_userId != null && _userId!.isNotEmpty) {
      _cartItems = await LocalStorage.getCart(_userId!) ?? [];
    } else {
      _cartItems = [];
    }
  }

  List<Map<String, dynamic>> get cartItems => _cartItems;

  // ✅ Add product (unique by "id") and save
  Future<bool> addItem(Map<String, dynamic> product) async {
    if (_userId == null || _userId!.isEmpty) return false;

    final exists = _cartItems.any((item) => item["id"] == product["id"]);

    if (exists) {
      return false; // already exists
    } else {
      _cartItems.add(product);
      await LocalStorage.saveCart(_userId!, _cartItems);
      return true;
    }
  }

  // ✅ Remove item and save
  Future<void> removeItem(int index) async {
    if (_userId == null || _userId!.isEmpty) return;

    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      await LocalStorage.saveCart(_userId!, _cartItems);
    }
  }

  // ✅ Clear cart for current user
  Future<void> clearCart() async {
    if (_userId == null || _userId!.isEmpty) return;

    _cartItems.clear();
    await LocalStorage.clearCart(_userId!);
  }

  // ✅ Reset when a new user logs in → load cart instead of clearing
  Future<void> resetForNewUser(String userId) async {
    _userId = userId;
    _cartItems = await LocalStorage.getCart(userId) ?? [];
  }
}
