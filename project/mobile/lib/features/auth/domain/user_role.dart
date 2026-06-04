import 'package:ytu_assistant/core/constants/app_constants.dart';

/// Roles supported by the backend (see `users.role CHECK ('student','professor')`).
enum UserRole {
  student,
  professor;

  /// Wire-format value the backend uses.
  String get wireValue => name;

  /// Human-readable label for the UI.
  String get label {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.professor:
        return 'Professor';
    }
  }

  /// Parses the backend's `role` string, case-insensitively.
  static UserRole fromString(String value) {
    final String normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'student':
        return UserRole.student;
      case 'professor':
        return UserRole.professor;
      default:
        throw ArgumentError.value(value, 'value', 'Unknown user role');
    }
  }

  /// Same as [fromString] but returns `null` instead of throwing.
  static UserRole? tryFromString(String? value) {
    if (value == null) {
      return null;
    }
    try {
      return fromString(value);
    } on ArgumentError {
      return null;
    }
  }

  /// Mirrors the backend's domain-based role derivation
  /// (utils/authUtils.js -> getRoleFromEmail).
  static UserRole? fromEmail(String email) {
    final String normalized = email.trim().toLowerCase();
    if (normalized.endsWith(AppConstants.studentEmailDomain)) {
      return UserRole.student;
    }
    if (normalized.endsWith(AppConstants.professorEmailDomain)) {
      return UserRole.professor;
    }
    return null;
  }
}
