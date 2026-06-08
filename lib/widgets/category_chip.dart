import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        // AnimatedContainer smoothly transitions
        // between selected/unselected states
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
            ? AppColors.primary
            : AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
              ? AppColors.primary
              : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: isSelected
              ? AppColors.background
              : AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}