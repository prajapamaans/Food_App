import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class FoodCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback? onTap;

  const FoodCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        // FIX: explicit height stops the overflow error.
        // Without this, Column inside horizontal ListView
        // has no height constraint → Flutter panics → yellow stripes.
        height: 260,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ─────────────────────────
            _buildImage(),

            // ── Info ──────────────────────────
            // Expanded fills remaining height after image(110px)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // spaceBetween pushes Add button to the bottom
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.name,
                      style: AppTextStyles.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    Text(
                      item.description,
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.formattedPrice,
                            style: AppTextStyles.price),
                        _buildRating(),
                      ],
                    ),

                    // Add to Cart button / Qty control
                    Consumer<CartProvider>(
                      builder: (context, cart, _) {
                        final qty = cart.quantityOf(item.id);
                        return qty > 0
                            ? _buildQtyControl(cart, qty)
                            : _buildAddButton(context, cart);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, CartProvider cart) {
    return SizedBox(
      width: double.infinity,
      height: 32,
      child: TextButton(
        onPressed: () => _addToCart(context, cart),
        style: TextButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 14),
            const SizedBox(width: 3),
            Text(
              'Add to Cart',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.background,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyControl(CartProvider cart, int qty) {
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          _qtyBtn(
            icon: qty == 1 ? Icons.delete_outline : Icons.remove,
            isDestructive: qty == 1,
            onTap: () => cart.decrementItem(item.id),
          ),
          Expanded(
            child: Text(
              '$qty',
              textAlign: TextAlign.center,
              style: AppTextStyles.label
                  .copyWith(color: AppColors.primary),
            ),
          ),
          _qtyBtn(
            icon: Icons.add,
            onTap: () => cart.addItem(item),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn({
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
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
          size: 14,
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
    );
  }

  void _addToCart(BuildContext context, CartProvider cart) {
    cart.addItem(item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${item.name} added to cart',
          style: AppTextStyles.bodySmall
              .copyWith(color: AppColors.background),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius:
          const BorderRadius.vertical(top: Radius.circular(20)),
      child: Stack(
        children: [
          Image.network(
            item.imageUrl,
            height: 110,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(
                height: 110,
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
              height: 110,
              color: AppColors.surfaceHigh,
              child: const Icon(Icons.restaurant,
                  color: AppColors.textHint, size: 40),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer_outlined,
                      size: 10, color: AppColors.primary),
                  const SizedBox(width: 3),
                  Text('${item.prepTimeMinutes}m',
                      style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRating() {
    return Row(
      children: [
        const Icon(Icons.star_rounded,
            size: 14, color: AppColors.primary),
        const SizedBox(width: 2),
        Text(
          item.formattedRating,
          style: AppTextStyles.caption
              .copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}