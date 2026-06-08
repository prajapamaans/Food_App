import 'package:flutter/material.dart';
import '../data/food_data.dart';
import '../models/food_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../widgets/food_card.dart';
import '../widgets/category_chip.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<FoodItem> get _filteredItems {
    if (_searchQuery.isNotEmpty) {
      return FoodData.search(_searchQuery);
    }
    return FoodData.getByCategory(_selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          // CustomScrollView lets us mix different
          // scroll behaviors (pinned headers, lists, grids)
          slivers: [
            // ── Header ──────────────────────────
            SliverToBoxAdapter(child: _buildHeader()),

            // ── Search Bar ──────────────────────
            SliverToBoxAdapter(child: _buildSearchBar()),

            // ── Featured (horizontal scroll) ────
            SliverToBoxAdapter(child: _buildFeaturedSection()),

            // ── Categories ──────────────────────
            SliverToBoxAdapter(child: _buildCategories()),

            // ── Section Title ───────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('All Dishes', style: AppTextStyles.h2),
                    TextButton(
                      onPressed: () {},
                      child: Text('See all',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
            ),

            // ── Food Grid ───────────────────────
            _buildFoodGrid(),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good Morning 👋',
                style: AppTextStyles.bodySmall),
              AppSpacing.gapXS,
              Text('What are you\ncraving today?',
                style: AppTextStyles.h1),
            ],
          ),
          // Avatar
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2),
            ),
            child: const Icon(Icons.person,
              color: AppColors.background, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.search,
              color: AppColors.textHint, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Search dishes, cuisines...',
                  hintStyle: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textHint),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            // Filter button
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.tune_rounded,
                color: AppColors.background, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Featured', style: AppTextStyles.h2),
              TextButton(
                onPressed: () {},
                child: Text('See all',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary)),
              ),
            ],
          ),
        ),

        // Horizontal scrolling cards
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: FoodData.topRated.length,
            separatorBuilder: (_, __) => AppSpacing.hGapMD,
            itemBuilder: (context, index) {
              final item = FoodData.topRated[index];
              return FoodCard(
                item: item,
                onTap: () => _openDetail(item),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: SizedBox(
        height: 46,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: FoodData.categories.length,
          separatorBuilder: (_, __) => AppSpacing.hGapSM,
          itemBuilder: (context, index) {
            final cat = FoodData.categories[index];
            return CategoryChip(
              label: cat,
              isSelected: _selectedCategory == cat,
              onTap: () => setState(() => _selectedCategory = cat),
            );
          },
        ),
      ),
    );
  }

  // SliverGrid = performant grid that works inside CustomScrollView
  Widget _buildFoodGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = _filteredItems[index];
            return FoodCard(
              item: item,
              onTap: () => _openDetail(item),
            );
          },
          childCount: _filteredItems.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,       // 2 columns
          crossAxisSpacing: 12,    // gap between columns
          mainAxisSpacing: 12,     // gap between rows
          childAspectRatio: 0.72,  // card height ratio
        ),
      ),
    );
  }

  void _openDetail(FoodItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(item: item)),
    );
  }
}