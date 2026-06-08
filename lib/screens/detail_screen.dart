import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../widgets/primary_button.dart';

class DetailScreen extends StatefulWidget {
  final FoodItem item;
  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _quantity = 1;

  double get _total => widget.item.price * _quantity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Scrollable content ─────────────────
          CustomScrollView(
            slivers: [
              _buildImageAppBar(),
              SliverToBoxAdapter(
                child: _buildContent(),
              ),
            ],
          ),

          // ── Bottom Add to Cart bar ─────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }

  // SliverAppBar = AppBar that collapses as you scroll
  Widget _buildImageAppBar() {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,               // stays visible when collapsed
      backgroundColor: AppColors.background,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new,
            color: AppColors.textPrimary, size: 18),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.item.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: AppColors.surfaceHigh,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              errorBuilder: (_, __, ___) =>
                Container(color: AppColors.surfaceHigh),
            ),
            // Bottom gradient so title is readable
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.background,
                  ],
                  stops: [0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(widget.item.name,
                  style: AppTextStyles.h1)),
              Text(widget.item.formattedPrice,
                style: AppTextStyles.price.copyWith(fontSize: 22)),
            ],
          ),

          AppSpacing.gapSM,

          // Rating + Reviews
          Row(
            children: [
              const Icon(Icons.star_rounded,
                size: 18, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(widget.item.formattedRating,
                style: AppTextStyles.label),
              const SizedBox(width: 4),
              Text('(${widget.item.reviewCount} reviews)',
                style: AppTextStyles.bodySmall),
            ],
          ),

          AppSpacing.gapLG,

          // ── Stats Row ─────────────────────────
          _buildStatsRow(),

          AppSpacing.gapLG,

          // Description
          Text('About this dish', style: AppTextStyles.h3),
          AppSpacing.gapSM,
          Text(widget.item.description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.7,
            )),

          AppSpacing.gapLG,

          // Quantity selector
          Text('Quantity', style: AppTextStyles.h3),
          AppSpacing.gapMD,
          _buildQuantitySelector(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statItem(Icons.local_fire_department_rounded,
          '${widget.item.calories}', 'Calories'),
        _divider(),
        _statItem(Icons.timer_outlined,
          '${widget.item.prepTimeMinutes} min', 'Prep Time'),
        _divider(),
        _statItem(Icons.people_outline_rounded,
          '1-2', 'Serving'),
      ],
    );
  }

  Widget _statItem(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            AppSpacing.gapXS,
            Text(value, style: AppTextStyles.label),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const SizedBox(width: 8);

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        _qtyButton(Icons.remove, () {
          if (_quantity > 1) setState(() => _quantity--);
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('$_quantity', style: AppTextStyles.h2),
        ),
        _qtyButton(Icons.add, () {
          setState(() => _quantity++);
        }),
      ],
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.divider),
        ),
        child: Icon(icon,
          color: AppColors.textPrimary, size: 18),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total price', style: AppTextStyles.caption),
              Text('\$${_total.toStringAsFixed(2)}',
                style: AppTextStyles.price.copyWith(fontSize: 20)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: PrimaryButton(
              label: 'Add to Cart 🛒',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${widget.item.name} added to cart!'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}