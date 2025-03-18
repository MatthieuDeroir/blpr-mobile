class AppConstants {
  AppConstants._();

  // Shared Preferences Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String usernameKey = 'username';
  static const String isLoggedInKey = 'is_logged_in';

  // Hive Box Names
  static const String userBox = 'user_box';
  static const String scalesBox = 'scales_box';
  static const String moodEntriesBox = 'mood_entries_box';
  static const String formulasBox = 'formulas_box';

  // Default Scale IDs
  static const String humeurScaleId = '9e28a52b-1a43-456d-be3d-85ec1d8d7dc5';
  static const String irritabiliteScaleId = 'a3cfcd9b-2608-4dce-a576-b0cab5894af5';
  static const String confianceScaleId = 'c7f09f47-c71f-4d2e-9e06-b53c6e9dec2f';
  static const String extraversionScaleId = 'd9b93e39-2d19-4af1-aae6-6895522bf81a';
  static const String bienEtreScaleId = 'f5a28535-76db-4aec-80c4-303c1497a707';

  // Default Formula ID
  static const String defaultFormulaId = 'b0c0b3b8-c8a3-44c0-8a9d-2c53813d882e';

  // Error Messages
  static const String connectionError = 'Please check your internet connection and try again';
  static const String serverError = 'Server error occurred. Please try again later';
  static const String unauthorizedError = 'Unauthorized access. Please login again';
  static const String defaultError = 'Something went wrong. Please try again';
}