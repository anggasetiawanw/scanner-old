import 'package:flutter/material.dart';

class CartItem {
  String id;
  double quantity;
  String scanData;
  String? itemCode;
  bool isValid = true;

  CartItem(
      {required this.id,
      required this.quantity,
      required this.scanData,
      required this.itemCode});
}

class Cart with ChangeNotifier {
  List<CartItem> _cart = [];
  List<CartItem> get cart {
    return [..._cart];
  }

  //Add Item to Cart
  void add(CartItem cartItem) {
    _cart.insert(0, cartItem);
    notifyListeners();
  }

  //Reset cart
  void clear() {
    _cart.clear();
    notifyListeners();
  }

  //set CartItem isValid to false
  void setInvalid(String itemCode) {
    _cart.where((item) => item.id == itemCode).first.isValid = false;
    notifyListeners();
  }

  //Remove an Item from Cart
  void removeItem(String id) {
    _cart.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  //Check if inputed CartItem is a duplicate
  bool isDuplicate(String code) {
    var duplicate = _cart.where((cartItem) => cartItem.scanData == code);
    if (duplicate.isEmpty) {
      return false;
    } else {
      return true;
    }
  }
}
