class ApiConfig {
  // Ganti IP address di sini saat development lokal Ipake IP address dari komputer kalian di terminal dengan perintah ipconfig (Windows) atau ifconfig (Linux/Mac)
  // terus cari IPv4 Address.

  static const String baseUrl =
      'http://192.168.1.9:8000'; //8000 jangan diganti ya cukup ganti yang di depan aja 'http://<IP_KAMU>:8000';

  // ---------------- AUTHENTICATION ----------------
  static Uri get signup => Uri.parse('$baseUrl/auth/signup/');
  static Uri get login => Uri.parse('$baseUrl/auth/login/');
  static Uri get forgotPassword => Uri.parse('$baseUrl/auth/forgot-password/');
  static Uri get resetPassword => Uri.parse('$baseUrl/auth/reset-password/');
  static Uri get verifyOtp => Uri.parse('$baseUrl/auth/verify-otp/');
  static Uri get profile => Uri.parse('$baseUrl/auth/profile/');

  // Debugging endpoint to check token validity
  static Uri get tokenVerify => Uri.parse('$baseUrl/auth/token/verify/');

  // ---------------- API (Fitness Data) ----------------
  static Uri get nutritionalTarget =>
      Uri.parse('$baseUrl/api/nutritional-target/');
  static Uri get foodIntake => Uri.parse('$baseUrl/api/food-intake/');
  // static Uri get dailySteps => Uri.parse('$baseUrl/api/daily-steps/');
  // static Uri get caloriesBurned => Uri.parse('$baseUrl/api/calories-burned/');
  static Uri get runningActivity => Uri.parse('$baseUrl/api/running-activity/');
  static Uri get runningStats => Uri.parse('$baseUrl/api/running-stats/');
  static Uri get cyclingStats => Uri.parse('$baseUrl/api/cycling-stats/');
  static Uri get dashboard => Uri.parse('$baseUrl/api/dashboard/');
  static Uri get updateProfile => Uri.parse('$baseUrl/api/profile-update/me/');
  static Uri get weeklyNutritionSummary =>
      Uri.parse('$baseUrl/api/nutrition-weekly-summary/');
  static Uri get monthlySummary => Uri.parse('$baseUrl/api/monthly-summary/');
  static Uri dailySummary(String date) =>
      Uri.parse('$baseUrl/api/nutritional-target/daily_summary/?date=$date');

  // NEW: Reminder API endpoint
  static Uri get reminders => Uri.parse('$baseUrl/api/reminders/');

  // Other constants
  static const int timeoutDuration = 15; // Seconds
}
