class MealCategory {
  final String id;
  final String name;
  final String imageUrl;

  const MealCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory MealCategory.fromJson(Map<String, dynamic> json) {
    return MealCategory(
      id:       json['idCategory'],
      name:     json['strCategory'],
      imageUrl: json['strCategoryThumb'],
    );
  }
}