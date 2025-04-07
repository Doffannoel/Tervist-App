class Reminder {
  final int? id;
  final String mealType;
  final String time;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  Reminder({
    this.id,
    required this.mealType,
    required this.time,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      mealType: json['meal_type'],
      time: json['time'],
      isActive: json['is_active'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meal_type': mealType,
      'time': time,
      'is_active': isActive,
    };
  }
}
