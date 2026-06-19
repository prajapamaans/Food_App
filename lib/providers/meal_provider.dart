import 'package:flutter/material.dart';
import '../models/meal_category.dart';
import '../models/meal.dart';
import '../services/meal_service.dart';

class MealProvider extends ChangeNotifier {
  final _service = MealService();

  // State
  List<MealCategory> _categories = [];
  Map<String, List<Meal>> _mealsByCategory = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  List<MealCategory> get categories    => _categories;
  Map<String, List<Meal>> get mealsByCategory => _mealsByCategory;
  bool     get isLoading => _isLoading;
  String?  get error     => _error;

  // Fetch everything
  Future<void> fetchAll() async {
    _isLoading = true;
    _error     = null;
    notifyListeners();

    try {
      // Step 1 — get categories
      _categories = await _service.fetchCategories();

      // Step 2 — get meals for first 14 categories only
      // (fetching all 14 categories at once = too many API calls)
      for (final cat in _categories.take(14 )) {
        final meals = await _service.fetchMealsByCategory(cat.name);
        _mealsByCategory[cat.name] = meals;
        notifyListeners(); // update UI as each category loads
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}