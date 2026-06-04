import 'package:ytu_assistant/features/auth/data/models/user_model.dart';
import 'package:ytu_assistant/features/auth/domain/user_role.dart';

/// Generic response envelope used by `/auth/login` and `/auth/register`.
///
/// - `/auth/login` → `{message, token, user}` (token + user populated)
/// - `/auth/register` → `{message, role}` (role populated, token + user null)
class AuthResponse {
  const AuthResponse({
    this.message,
    this.token,
    this.user,
    this.role,
  });

  /// Server message, e.g. "Login successful" or "User registered. Verification code sent."
  final String? message;

  /// JWT (only populated by `/auth/login`).
  final String? token;

  /// User payload (only populated by `/auth/login`).
  final UserModel? user;

  /// Role inferred from email at registration. Populated by `/auth/register`.
  final UserRole? role;

  bool get hasSession => token != null && user != null;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final dynamic rawUser = json['user'];
    return AuthResponse(
      message: json['message'] as String?,
      token: json['token'] as String?,
      user: rawUser is Map<String, dynamic>
          ? UserModel.fromJson(rawUser)
          : null,
      role: UserRole.tryFromString(json['role'] as String?),
    );
  }
}
