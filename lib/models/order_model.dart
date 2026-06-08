// lib/models/order_model.dart
class OrderModel {
  final String id;
  final DateTime date;
  final double total;
  final int itemCount;

  const OrderModel({
    required this.id,
    required this.date,
    required this.total,
    required this.itemCount,
  });
}