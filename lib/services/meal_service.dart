import 'package:dio/dio.dart';
import '../models/meal_category.dart';
import '../models/meal.dart';

class MealService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://www.themealdb.com/api/json/v1/1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Fetch all categories
  Future<List<MealCategory>> fetchCategories() async {
    try {
      final response = await _dio.get('/categories.php');
      final List data = response.data['categories'];
      return data.map((e) => MealCategory.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load categories: ${e.message}');
    }
  }

  // Fetch meals by category name
  Future<List<Meal>> fetchMealsByCategory(String category) async {
    try {
      final response = await _dio.get(
        '/filter.php',
        queryParameters: {'c': category},
      );
      final List data = response.data['meals'];
      return data.map((e) => Meal.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load meals: ${e.message}');
    }
  }
}
