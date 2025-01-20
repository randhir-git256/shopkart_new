import 'package:flutter/material.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  List<Product> get cart => _items.values.map((item) => item.product).toList();

  void addToCart(Product product, [int quantity = 1]) {
    if (_items.containsKey(product.id)) {
      updateQuantity(product, _items[product.id]!.quantity + quantity);
    } else {
      _items[product.id] = CartItem(product: product, quantity: quantity);
    }
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _items.remove(product.id);
    notifyListeners();
  }

  void updateQuantity(Product product, int quantity) {
    if (_items.containsKey(product.id)) {
      if (quantity <= 0) {
        removeFromCart(product);
      } else {
        _items[product.id] = CartItem(product: product, quantity: quantity);
        notifyListeners();
      }
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  double get totalPrice => _items.values.fold(
        0,
        (sum, item) => sum + (item.product.price * item.quantity),
      );
}

class CartItem {
  final Product product;
  final int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });
}
