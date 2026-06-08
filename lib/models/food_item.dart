// WHY a model class?
// → Gives your data a SHAPE
// → Instead of random Maps everywhere, you have
//   structured, type-safe objects
// → foodItem.name is safer than map['name']

class FoodItem {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final double rating;
  final int reviewCount;
  final String category;
  final int calories;
  final int prepTimeMinutes;

  // Constructor — const makes it compile-time constant
  // = faster performance
  const FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.category,
    required this.calories,
    required this.prepTimeMinutes,
  });

  // Helper: formatted price string
  String get formattedPrice => '₹${price.toStringAsFixed(0)}';

  // Helper: formatted rating
  String get formattedRating => rating.toStringAsFixed(1);
}