class ApiConstants {
  ApiConstants._();

  // Base URL
  static const String baseUrl = 'http://localhost:3000';

  // Authentication Endpoints
  static const String register = '/api/users/register';
  static const String login = '/api/users/login';
  static const String currentUser = '/api/users/me';

  // Scale Endpoints
  static const String scales = '/api/scales';
  static String scale(String id) => '$scales/$id';

  // Mood Entry Endpoints
  static const String moodEntries = '/api/mood-entries';
  static String moodEntry(String id) => '$moodEntries/$id';

  // Stability Formula Endpoints
  static const String formulas = '/api/stability-formulas';
  static const String activeFormula = '$formulas/active';
  static String formula(String id) => '$formulas/$id';

  // AI Assessment Endpoints
  static const String aiChat = '/api/ai-assessment/chat';
  static const String aiAssess = '/api/ai-assessment/assess';
  static const String aiSaveAssessment = '/api/ai-assessment/save-assessment';
}