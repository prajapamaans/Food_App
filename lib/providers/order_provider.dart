// lib/providers/order_provider.dart
import 'package:flutter/material.dart';
import '../models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  final List<OrderModel> _orders = [];

  List<OrderModel> get orders => _orders;

  void addOrder({
    required String id,
    required double total,
    required int itemCount,
  }) {
    _orders.insert(
      0,
      OrderModel(
        id: id,
        date: DateTime.now(),
        total: total,
        itemCount: itemCount,
      ),
    );
    notifyListeners();
  }
}
