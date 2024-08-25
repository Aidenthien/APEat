import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  Map<String, Map<String, dynamic>> _cartItems = {};

  Map<String, Map<String, dynamic>> get cartItems => _cartItems;

  void addItem(String foodName, Map<String, dynamic> foodData) {
    if (_cartItems.containsKey(foodName)) {
      _cartItems[foodName]!['quantity'] += 1;
    } else {
      _cartItems[foodName] = {
        'quantity': 1,
        'stall_name': foodData['stall_name'],
        'price': foodData['food_price'],
        'description': foodData['food_description'],
        'image': foodData['food_image_url'],
      };
    }
    notifyListeners();
  }

  void removeItem(String foodName) {
    if (_cartItems.containsKey(foodName) &&
        _cartItems[foodName]!['quantity'] > 0) {
      _cartItems[foodName]!['quantity'] -= 1;
      if (_cartItems[foodName]!['quantity'] == 0) {
        _cartItems.remove(foodName);
      }
    }
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  double getTotalCartPrice() {
    double total = 0.0;
    _cartItems.forEach((key, value) {
      total += value['price'] * value['quantity'];
    });
    return total;
  }

  int getTotalCartQuantity() {
    int total = 0;
    _cartItems.forEach((key, value) {
      total += value['quantity'] as int;
    });
    return total;
  }
}
