class SignupData {
  String? email;
  String? password;
  String? confirmPassword;
  String? username;
  String? gender;
  double? weight;
  double? height;
  int? age;
  String? activityLevel;
  String? goal;
  double? targetWeight;
  String? timeline;

  Map<String, dynamic> toJson() => {
        "email": email,
        "username": username,
        "gender": gender,
        "weight": weight,
        "height": height,
        "age": age,
        "activity_level": activityLevel,
        "goal": formatGoal(goal),
        "target_weight":
            formatGoal(goal) != 'Maintain Weight' ? targetWeight : null,
        "timeline": formatGoal(goal) != 'Maintain Weight'
            ? (timeline?.split(' ').last ?? 'Weeks') // Fix di sini
            : null,
        "password": password,
        "confirm_password": confirmPassword,
      };

  String? formatGoal(String? goal) {
    switch (goal) {
      case 'Weight gain':
        return 'Weight Gain';
      case 'Maintain my current weight':
        return 'Maintain Weight';
      case 'Weight loss':
        return 'Weight Loss';
      default:
        return goal;
    }
  }
}
