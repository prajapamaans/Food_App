import 'dart:math';

class Meal {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final double rating;
  final String description;

  const Meal({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.description,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    final random = Random(json['idMeal'].hashCode);
    return Meal(
      id:          json['idMeal'],
      name:        json['strMeal'],
      imageUrl:    json['strMealThumb'],
      price:       (random.nextInt(600) + 99).toDouble(),
      rating:      3.5 + random.nextDouble() * 1.5,
      description: _descriptions[random.nextInt(_descriptions.length)],
    );
  }

  String get formattedPrice => '₹${price.toStringAsFixed(0)}';
  String get formattedRating => rating.toStringAsFixed(1);

  static const List<String> _descriptions = [
    'Freshly prepared with premium ingredients',
    'A classic recipe loved by thousands',
    'Bursting with authentic flavors',
    'Made fresh daily with local produce',
    'A crowd favorite with rich taste',
    'Slow cooked to perfection',
    'Bold flavors in every bite',
    'Traditional recipe with a modern twist',
  ];
}