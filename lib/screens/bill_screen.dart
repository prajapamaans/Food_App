import 'package:flutter/material.dart';
import '../providers/cart_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../widgets/primary_button.dart';
import 'main_screen.dart';

class BillScreen extends StatelessWidget {
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

  // Generate a mock order number — looks real to interviewers
  String get _orderNumber {
    final now = DateTime.now();
    return 'QB${now.millisecondsSinceEpoch.toString().substring(7)}';
  }

  @override
  Widget build(BuildContext context) {
    final orderNo = _orderNumber; // capture once so it doesn't change on rebuild

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screen,
          child: Column(
            children: [
              AppSpacing.gapMD,

              // ── Success icon ─────────────────────────────────────────────
              _buildSuccessHeader(),

              AppSpacing.gapXL,

              // ── Order number card ────────────────────────────────────────
              _buildOrderNumberCard(orderNo),

              AppSpacing.gapMD,

              // ── Itemized receipt ─────────────────────────────────────────
              _buildItemizedReceipt(),

              AppSpacing.gapMD,

              // ── Price breakdown ──────────────────────────────────────────
              _buildPriceBreakdown(),

              AppSpacing.gapMD,

              // ── Delivery info ────────────────────────────────────────────
              _buildDeliveryInfo(),

              AppSpacing.gapXL,

              // ── Actions ──────────────────────────────────────────────────
              PrimaryButton(
                label: 'Back to Home',
                onTap: () {
                  // Pop ALL routes and go to MainScreen fresh
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MainScreen()),
                    (route) => false, // remove everything
                  );
                },
              ),

              AppSpacing.gapMD,

              TextButton(
                onPressed: () => Navigator.pop(context),
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

  // ── Success Header ────────────────────────────────────────────────────────

  Widget _buildSuccessHeader() {
    return Column(
      children: [
        // Animated-looking success circle
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

  // ── Order Number Card ─────────────────────────────────────────────────────

  Widget _buildOrderNumberCard(String orderNo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.25),
        ),
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
          Text(
            _formattedDateTime(),
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  // ── Itemized Receipt ──────────────────────────────────────────────────────

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

          // One row per cart item
          ...items.map((item) => _buildReceiptRow(item)),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(CartItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Quantity badge
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

          // Item name
          Expanded(
            child: Text(
              item.food.name,
              style: AppTextStyles.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Line total
          Text(
            '\$${item.subtotal.toStringAsFixed(2)}',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ── Price Breakdown ───────────────────────────────────────────────────────

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
          _priceRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
          AppSpacing.gapXS,
          _priceRow('Delivery Fee', '\$${deliveryFee.toStringAsFixed(2)}'),
          AppSpacing.gapXS,
          _priceRow('Tax (8%)', '\$${tax.toStringAsFixed(2)}'),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AppColors.divider),
          ),

          // Grand total — bigger, accented
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Paid',
                  style: AppTextStyles.bodyLarge
                      .copyWith(fontWeight: FontWeight.w700)),
              Text(
                '\$${grandTotal.toStringAsFixed(2)}',
                style: AppTextStyles.h2
                    .copyWith(color: AppColors.primary),
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

  // ── Delivery Info ─────────────────────────────────────────────────────────

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
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formattedDateTime() {
    final now = DateTime.now();
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final amPm = now.hour >= 12 ? 'PM' : 'AM';
    final minute = now.minute.toString().padLeft(2, '0');
    return '${now.day} ${months[now.month - 1]} ${now.year}  •  $hour:$minute $amPm';
  }
}