import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/food_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MealProvider>();
      if (provider.categories.isEmpty) {
        provider.fetchAll();
      }
    });
  }



 @override
Widget build(BuildContext context) {
  final provider = context.watch<MealProvider>();

  return Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          Expanded(
            child: provider.isLoading && provider.categories.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : (_searchQuery.isEmpty
                    ? _buildCategorizedList(provider)
                    : _buildFilteredList(provider)),
          ),
        ],
      ),
    ),
  );
}

Widget _buildCategorizedList(MealProvider provider) {
  return ListView.builder(
    padding: const EdgeInsets.only(bottom: 24),
    itemCount: provider.categories.length,
    itemBuilder: (context, index) {
      final category = provider.categories[index];
      final meals = provider.mealsByCategory[category.name] ?? [];
      return _buildCategorySection(category.name, meals);
    },
  );
}

Widget _buildFilteredList(MealProvider provider) {
  // Flatten all meals from every category into one list
  final allMeals = provider.mealsByCategory.values
      .expand((mealList) => mealList)
      .toList();

  // Filter by name, case-insensitive
  final filtered = allMeals
      .where((meal) =>
          meal.name.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  if (filtered.isEmpty) {
    return Center(
      child: Text(
        'No meals found for "$_searchQuery"',
        style: AppTextStyles.bodySmall,
      ),
    );
  }

  return GridView.builder(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.72,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
    ),
    itemCount: filtered.length,
    itemBuilder: (context, index) => _buildMealCard(filtered[index]),
  );
}

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Text('What are you craving?', style: AppTextStyles.h1),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search for meals or restaurants',
          prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(String category, List meals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category title row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category, style: AppTextStyles.h2),
              Text(
                'See all',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        // Horizontal scroll of meal cards
        SizedBox(
          height: 280,
          child: meals.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final meal = meals[index];
                    return _buildMealCard(meal);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMealCard(meal) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              meal.imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 120,
                color: AppColors.surfaceHigh,
                child: const Icon(Icons.fastfood, color: AppColors.textHint),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  meal.name,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 2),

                // Description
                Text(
                  meal.description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Price + Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      meal.formattedPrice,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          meal.formattedRating,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Add to Cart button
                // Add to Cart button
                Consumer<CartProvider>(
                  builder: (context, cart, _) {
                    final quantity = cart.quantityOf(meal.id);
                    if (quantity == 0) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final foodItem = FoodItem(
                              id: meal.id,
                              name: meal.name,
                              description: meal.description,
                              imageUrl: meal.imageUrl,
                              price: meal.price,
                              rating: meal.rating,
                              reviewCount: 0,
                              category: '',
                              calories: 0,
                              prepTimeMinutes: 0,
                            );
                            context.read<CartProvider>().addItem(foodItem);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            '+ Add to Cart',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => context
                              .read<CartProvider>()
                              .decrementItem(meal.id),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.remove,
                              size: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Text(
                          '$quantity',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            final foodItem = FoodItem(
                              id: meal.id,
                              name: meal.name,
                              description: meal.description,
                              imageUrl: meal.imageUrl,
                              price: meal.price,
                              rating: meal.rating,
                              reviewCount: 0,
                              category: '',
                              calories: 0,
                              prepTimeMinutes: 0,
                            );
                            context.read<CartProvider>().addItem(foodItem);
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
