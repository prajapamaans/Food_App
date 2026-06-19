import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String name;
  final double price;
  final int quantity;

  const OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'price': price,
        'quantity': quantity,
      };

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
        name: map['name'] as String,
        price: (map['price'] as num).toDouble(),
        quantity: map['quantity'] as int,
      );
}

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double grandTotal;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.grandTotal,
    required this.createdAt,
  });

  factory OrderModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: data['userId'] as String,
      items: (data['items'] as List)
          .map((i) => OrderItem.fromMap(i as Map<String, dynamic>))
          .toList(),
      subtotal: (data['subtotal'] as num).toDouble(),
      deliveryFee: (data['deliveryFee'] as num).toDouble(),
      tax: (data['tax'] as num).toDouble(),
      grandTotal: (data['grandTotal'] as num).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}