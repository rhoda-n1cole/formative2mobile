import 'constants.dart';

class Validators {
  static bool isAluEmail(String email) {
    final e = email.trim().toLowerCase();
    return AppConstants.allowedEmailDomains.any((d) => e.endsWith('@$d'));
  }

  static String? email(String? v) {
    final value = v?.trim().toLowerCase() ?? '';
    if (value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    if (!isAluEmail(value)) {
      return 'Use your ALU email (${AppConstants.allowedEmailDomains.map((d) => '@$d').join(' or ')})';
    }
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? required(String? v, String field) {
    if (v == null || v.trim().isEmpty) return '$field is required';
    return null;
  }
}
