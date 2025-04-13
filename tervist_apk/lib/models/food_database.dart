class FoodDatabase {
  final int id;
  final String name;
  final List<FoodMeasurement> measurements;
  bool selected;

  FoodDatabase({
    required this.id,
    required this.name,
    required this.measurements,
    this.selected = false,
  });

  factory FoodDatabase.fromJson(Map<String, dynamic> json) {
    final measurementsJson = json['measurements'] as List<dynamic>? ?? [];

    return FoodDatabase(
      id: json['id'],
      name: json['name'],
      measurements:
          measurementsJson.map((e) => FoodMeasurement.fromJson(e)).toList(),
    );
  }
}

class FoodMeasurement {
  final int id; // Add this field
  final String label;
  final double gramEquivalent;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double saturatedFat;
  final double polyunsaturatedFat;
  final double monounsaturatedFat;
  final double cholesterol;
  final double sodium;
  final double dietaryFiber;
  final double totalSugars;
  final double potassium;
  final double vitaminA;
  final double vitaminC;
  final double calcium;
  final double iron;

  FoodMeasurement({
    required this.id,
    required this.label,
    required this.gramEquivalent,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.saturatedFat,
    required this.polyunsaturatedFat,
    required this.monounsaturatedFat,
    required this.cholesterol,
    required this.sodium,
    required this.dietaryFiber,
    required this.totalSugars,
    required this.potassium,
    required this.vitaminA,
    required this.vitaminC,
    required this.calcium,
    required this.iron,
  });

  factory FoodMeasurement.fromJson(Map<String, dynamic> json) {
    return FoodMeasurement(
      id : json['id'],
      label: json['label'],
      gramEquivalent: json['gram_equivalent']?.toDouble() ?? 0.0,
      calories: json['calories']?.toDouble() ?? 0.0,
      protein: json['protein']?.toDouble() ?? 0.0,
      carbs: json['carbs']?.toDouble() ?? 0.0,
      fat: json['fat']?.toDouble() ?? 0.0,
      saturatedFat: json['saturated_fat']?.toDouble() ?? 0.0,
      polyunsaturatedFat: json['polyunsaturated_fat']?.toDouble() ?? 0.0,
      monounsaturatedFat: json['monounsaturated_fat']?.toDouble() ?? 0.0,
      cholesterol: json['cholesterol']?.toDouble() ?? 0.0,
      sodium: json['sodium']?.toDouble() ?? 0.0,
      dietaryFiber: json['dietary_fiber']?.toDouble() ?? 0.0,
      totalSugars: json['total_sugars']?.toDouble() ?? 0.0,
      potassium: json['potassium']?.toDouble() ?? 0.0,
      vitaminA: json['vitamin_a']?.toDouble() ?? 0.0,
      vitaminC: json['vitamin_c']?.toDouble() ?? 0.0,
      calcium: json['calcium']?.toDouble() ?? 0.0,
      iron: json['iron']?.toDouble() ?? 0.0,
    );
  }
}
