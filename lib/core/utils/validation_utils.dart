/// Utility class for form validation
class ValidationUtils {
  /// Validates an email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );

    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates a password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    return null;
  }

  /// Validates a username
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }

    if (value.length > 30) {
      return 'Username cannot exceed 30 characters';
    }

    return null;
  }

  /// Validates scale name
  static String? validateScaleName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Scale name is required';
    }

    if (value.length < 2) {
      return 'Scale name must be at least 2 characters long';
    }

    if (value.length > 100) {
      return 'Scale name cannot exceed 100 characters';
    }

    return null;
  }

  /// Validates scale description
  static String? validateScaleDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Scale description is required';
    }

    if (value.length > 500) {
      return 'Scale description cannot exceed 500 characters';
    }

    return null;
  }

  /// Validates a mood entry comment (optional field)
  static String? validateMoodComment(String? value) {
    if (value != null && value.length > 1000) {
      return 'Comment cannot exceed 1000 characters';
    }

    return null;
  }

  /// Validates sleep hours entry
  static String? validateSleepHours(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    final double? hours = double.tryParse(value);

    if (hours == null) {
      return 'Please enter a valid number';
    }

    if (hours < 0) {
      return 'Hours cannot be negative';
    }

    if (hours > 24) {
      return 'Hours cannot exceed 24';
    }

    return null;
  }

  /// Validates scale level value
  static String? validateScaleLevel(String? value, int minValue, int maxValue) {
    if (value == null || value.isEmpty) {
      return 'Level value is required';
    }

    final int? level = int.tryParse(value);

    if (level == null) {
      return 'Please enter a valid number';
    }

    if (level < minValue) {
      return 'Level cannot be less than $minValue';
    }

    if (level > maxValue) {
      return 'Level cannot exceed $maxValue';
    }

    return null;
  }
}