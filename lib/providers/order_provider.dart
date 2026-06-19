import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../providers/cart_provider.dart';

class OrderProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> placeOrder(CartProvider cart) async {
    final user = _auth.currentUser;
    debugPrint('CURRENT USER: ${user?.uid}');
  debugPrint('CART IS EMPTY: ${cart.isEmpty}');
  debugPrint('CART ITEM COUNT: ${cart.items.length}');
    if (user == null) return false;
    if (cart.isEmpty) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final orderItems = cart.items
          .map((cartItem) => OrderItem(
                name: cartItem.food.name,
                price: cartItem.food.price,
                quantity: cartItem.quantity,
              ))
          .toList();

      await _firestore.collection('orders').add({
        'userId': user.uid,
        'items': orderItems.map((i) => i.toMap()).toList(),
        'subtotal': cart.subtotal,
        'deliveryFee': cart.deliveryFee,
        'tax': cart.tax,
        'grandTotal': cart.grandTotal,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await fetchOrders();
      return true;
    } catch (e) {
      _error = 'Failed to place order. Try again.';
      debugPrint('ORDER SAVE ERROR: $e'); 
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrders() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      _orders = snapshot.docs
          .map((doc) => OrderModel.fromDoc(doc))
          .toList();
    } catch (e) {
      _error = 'Failed to load orders.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}