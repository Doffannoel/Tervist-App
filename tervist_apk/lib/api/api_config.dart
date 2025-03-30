class ApiConfig {
  // Ganti IP address di sini saat development lokal Ipake IP address dari komputer kalian di terminal dengan perintah ipconfig (Windows) atau ifconfig (Linux/Mac)
  // terus cari IPv4 Address.
  
  static const String baseUrl = 'http://192.168.18.49:8000'; //8000 jangan diganti ya cukup ganti yang di depan aja 'http://<IP_KAMU>:8000';

  // ---------------- AUTHENTICATION ----------------
  static Uri get signup => Uri.parse('$baseUrl/auth/signup/');
  static Uri get login => Uri.parse('$baseUrl/auth/login/');
  static Uri get forgotPassword => Uri.parse('$baseUrl/auth/forgot-password/');
  static Uri get resetPassword => Uri.parse('$baseUrl/auth/reset-password/');
  static Uri get profile => Uri.parse('$baseUrl/auth/profile/');

  // ---------------- API (Fitness Data) ----------------
  static Uri get nutritionalTarget =>
      Uri.parse('$baseUrl/api/nutritional-target/');
  static Uri get foodIntake => Uri.parse('$baseUrl/api/food-intake/');
  static Uri get dailySteps => Uri.parse('$baseUrl/api/daily-steps/');
  static Uri get caloriesBurned => Uri.parse('$baseUrl/api/calories-burned/');
  static Uri get runningActivity => Uri.parse('$baseUrl/api/running-activity/');
  static Uri get dashboard => Uri.parse('$baseUrl/api/dashboard/');
  static Uri get weeklyNutritionSummary =>
      Uri.parse('$baseUrl/api/nutrition-weekly-summary/');

}
