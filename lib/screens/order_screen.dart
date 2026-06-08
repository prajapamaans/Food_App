import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      body: orders.isEmpty
          ? const Center(
              child: Text('No orders yet!'),
            )
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Text(
                      order.itemCount.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text('Order ${order.id}'),
                  subtitle: Text(
                    '${order.date.day}/${order.date.month}/${order.date.year}  ${order.date.hour}:${order.date.minute.toString().padLeft(2, '0')} - ₹${order.total.toStringAsFixed(2)}',
                  ),
                );
         },
          ),
      
  );
  }
}