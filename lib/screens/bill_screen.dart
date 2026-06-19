import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../widgets/primary_button.dart';
import 'main_screen.dart';
import 'order_screen.dart';

class BillScreen extends StatefulWidget {
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double grandTotal;

  const BillScreen({
    super.key,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.grandTotal,
  });

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  bool _orderSaved = false;
  bool _isSaving = true;

  // Generate order number
  String get _orderNumber {
    final now = DateTime.now();
    return 'QB${now.millisecondsSinceEpoch.toString().substring(7)}';
  }

  @override
  void initState() {
    super.initState();
    _saveOrder();
  }

  // Save order to Firestore as soon as BillScreen opens
  Future<void> _saveOrder() async {
    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();


    final success = await orderProvider.placeOrder(cart);


    if (mounted) {
      setState(() {
        _orderSaved = success;
        _isSaving = false;
      });

      // Clear cart after saving
      if (success) cart.clearCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderNo = _orderNumber;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screen,
          child: Column(
            children: [
              AppSpacing.gapMD,

              // Show spinner while saving, success/fail after
              _isSaving
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _buildSuccessHeader(),

              AppSpacing.gapXL,

              _buildOrderNumberCard(orderNo),
              AppSpacing.gapMD,
              _buildItemizedReceipt(),
              AppSpacing.gapMD,
              _buildPriceBreakdown(),
              AppSpacing.gapMD,
              _buildDeliveryInfo(),
              AppSpacing.gapXL,

              // Show error banner if save failed
              if (!_isSaving && !_orderSaved)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Order placed but failed to save history. Contact support.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),

              PrimaryButton(
                label: 'Back to Home',
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                    (route) => false,
                  );
                },
              ),

              AppSpacing.gapMD,

              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 2)),
                    (route) => false,
                  );
                },
                child: Text(
                  'View Order History',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.primary),
                ),
              ),

              AppSpacing.gapXL,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.primary,
            size: 48,
          ),
        ),
        AppSpacing.gapMD,
        Text('Order Confirmed!', style: AppTextStyles.h1),
        AppSpacing.gapXS,
        Text(
          'Your food is being prepared',
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOrderNumberCard(String orderNo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text('Order Number',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary)),
          AppSpacing.gapXS,
          Text(
            '#$orderNo',
            style: AppTextStyles.h1.copyWith(
              color: AppColors.primary,
              letterSpacing: 1.5,
            ),
          ),
          AppSpacing.gapXS,
          Text(_formattedDateTime(), style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildItemizedReceipt() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text('Items Ordered',
                style: AppTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.w600)),
          ),
          const Divider(color: AppColors.divider, height: 1),
          ...widget.items.map((item) => _buildReceiptRow(item)),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(CartItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '${item.quantity}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.food.name,
              style: AppTextStyles.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '₹${item.subtotal.toStringAsFixed(2)}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _priceRow('Subtotal', '₹${widget.subtotal.toStringAsFixed(2)}'),
          AppSpacing.gapXS,
          _priceRow('Delivery Fee', '₹${widget.deliveryFee.toStringAsFixed(2)}'),
          AppSpacing.gapXS,
          _priceRow('Tax (8%)', '₹${widget.tax.toStringAsFixed(2)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AppColors.divider),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Paid',
                  style: AppTextStyles.bodyLarge
                      .copyWith(fontWeight: FontWeight.w700)),
              Text(
                '₹${widget.grandTotal.toStringAsFixed(2)}',
                style: AppTextStyles.h2.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        Text(value,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildDeliveryInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.delivery_dining_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Estimated Delivery',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
                AppSpacing.gapXS,
                Text('25 – 35 minutes',
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'On the way',
              style: AppTextStyles.caption.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formattedDateTime() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final amPm = now.hour >= 12 ? 'PM' : 'AM';
    final minute = now.minute.toString().padLeft(2, '0');
    return '${now.day} ${months[now.month - 1]} ${now.year}  •  $hour:$minute $amPm';
  }
}