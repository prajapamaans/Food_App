import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../models/order_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch orders from Firestore when screen opens
    Future.microtask(() =>
        context.read<OrderProvider>().fetchOrders());
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Your Orders', style: AppTextStyles.h2),
        elevation: 0,
      ),
      body: orderProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : orderProvider.orders.isEmpty
              ? Center(
                  child: Text('No orders yet!', style: AppTextStyles.bodySmall),
                )
              : ListView.builder(
                  padding: AppSpacing.screen,
                  itemCount: orderProvider.orders.length,
                  itemBuilder: (context, index) {
                    final order = orderProvider.orders[index];
                    return _buildOrderCard(order);
                  },
                ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID + date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.id.substring(0, 8)}',
                style: AppTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                _formatDate(order.createdAt),
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 12),

          // Items list
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.quantity}x ${item.name}',
                      style: AppTextStyles.bodySmall,
                    ),
                    Text(
                      '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 12),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 12),

          // Grand total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: AppTextStyles.bodyLarge
                      .copyWith(fontWeight: FontWeight.w700)),
              Text(
                '₹${order.grandTotal.toStringAsFixed(2)}',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}