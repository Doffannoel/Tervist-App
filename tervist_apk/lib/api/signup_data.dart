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
        "goal": goal,
        "target_weight": goal != 'Maintain Weight' ? targetWeight : null,
        "timeline": goal != 'Maintain Weight' ? timeline : null,
        "password": password,
        "confirm_password": confirmPassword,
      };
}
