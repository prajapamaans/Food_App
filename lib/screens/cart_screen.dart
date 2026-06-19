import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../widgets/primary_button.dart';
import 'bill_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            // Consumer rebuilds only this subtree when cart changes.
            // This is more efficient than Provider.of with listen: true
            // on the whole screen.
            Expanded(
              child: Consumer<CartProvider>(
                builder: (context, cart, _) {
                  if (cart.isEmpty) return _buildEmptyState();
                  return _buildCartContent(context, cart);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Text('My Cart', style: AppTextStyles.h1),
          const Spacer(),
          // Show item count badge
          Consumer<CartProvider>(
            builder: (_, cart, __) => cart.isEmpty
                ? const SizedBox.shrink()
                : Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${cart.totalItems} item${cart.totalItems != 1 ? 's' : ''}',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 72, color: AppColors.textHint),
          AppSpacing.gapMD,
          Text('Your cart is empty', style: AppTextStyles.h2),
          AppSpacing.gapXS,
          Text(
            'Add items from the menu to get started',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Cart Content ──────────────────────────────────────────────────────────

  Widget _buildCartContent(BuildContext context, CartProvider cart) {
    return Column(
      children: [
        // Scrollable item list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            itemCount: cart.items.length,
            separatorBuilder: (_, __) =>
                const Divider(color: AppColors.divider, height: 1),
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return _buildCartItem(context, item, cart);
            },
          ),
        ),

        // Order summary + place order button
        _buildOrderSummary(context, cart),
      ],
    );
  }

  // ── Single Cart Item Row ──────────────────────────────────────────────────

  Widget _buildCartItem(
      BuildContext context, CartItem item, CartProvider cart) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Food image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.food.imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(
                  width: 64,
                  height: 64,
                  color: AppColors.surfaceHigh,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fastfood,
                    color: AppColors.textHint, size: 28),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Name + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.food.name,
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                AppSpacing.gapXS,
                Text(
                  item.food.formattedPrice,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Quantity controls
          _buildQuantityControl(item, cart),
        ],
      ),
    );
  }

  // ── +/- Quantity Control ──────────────────────────────────────────────────

  Widget _buildQuantityControl(CartItem item, CartProvider cart) {
    return Row(
      children: [
        _qtyButton(
          icon: item.quantity == 1 ? Icons.delete_outline : Icons.remove,
          onTap: () => cart.decrementItem(item.food.id),
          isDestructive: item.quantity == 1,
        ),
        SizedBox(
          width: 32,
          child: Text(
            '${item.quantity}',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge
                .copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        _qtyButton(
          icon: Icons.add,
          onTap: () => cart.addItem(item.food),
        ),
      ],
    );
  }

  Widget _qtyButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withOpacity(0.1)
              : AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDestructive
                ? AppColors.error.withOpacity(0.3)
                : AppColors.divider,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
    );
  }

  // ── Order Summary Card ────────────────────────────────────────────────────

  Widget _buildOrderSummary(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Price rows
          _summaryRow('Subtotal', '₹${cart.subtotal.toStringAsFixed(2)}'),
          AppSpacing.gapXS,
          _summaryRow('Delivery fee', '₹${cart.deliveryFee.toStringAsFixed(2)}'),
          AppSpacing.gapXS,
          _summaryRow('Tax (8%)', '₹${cart.tax.toStringAsFixed(2)}'),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AppColors.divider),
          ),

          // Grand total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.h2),
              Text(
                '₹${cart.grandTotal.toStringAsFixed(2)}',
                style: AppTextStyles.h2
                    .copyWith(color: AppColors.primary),
              ),
            ],
          ),

          AppSpacing.gapMD,

          // Place order button
          PrimaryButton(
            label: 'Place Order  →  ₹${cart.grandTotal.toStringAsFixed(2)}',
            onTap: () => _placeOrder(context, cart),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
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

  // ── Place Order Logic ─────────────────────────────────────────────────────

  void _placeOrder(BuildContext context, CartProvider cart) {
    // CRITICAL: Capture data BEFORE clearing cart.
    // Once clearCart() is called, cart.items is empty.
    final orderItems = List<CartItem>.from(cart.items);
    final orderTotal = cart.grandTotal;
    final orderSubtotal = cart.subtotal;
    final orderDelivery = cart.deliveryFee;
    final orderTax = cart.tax;

    

    // Navigate to bill — pushReplacement so Back doesn't return to cart
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BillScreen(
          items: orderItems,
          subtotal: orderSubtotal,
          deliveryFee: orderDelivery,
          tax: orderTax,
          grandTotal: orderTotal,
        ),
      ),
    );
  }
}