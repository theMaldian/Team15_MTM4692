/// Request DTOs for `/auth/*` endpoints. JSON keys mirror the backend exactly.
library;

/// `POST /auth/register`
///
/// Backend (services/authService.js `registerUser`) only reads
/// `email, password, first_name, last_name`. Extra fields are ignored —
/// faculty/department are filled in later via `PUT /profile`.
class RegisterRequest {
  const RegisterRequest({
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
  });

  final String email;
  final String password;
  final String? firstName;
  final String? lastName;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'email': email,
        'password': password,
        if (firstName != null && firstName!.isNotEmpty) 'first_name': firstName,
        if (lastName != null && lastName!.isNotEmpty) 'last_name': lastName,
      };
}

/// `POST /auth/login`
class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'email': email,
        'password': password,
      };
}

/// `POST /auth/verify-email`
class VerifyEmailRequest {
  const VerifyEmailRequest({required this.email, required this.code});

  final String email;
  final String code;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'email': email,
        'code': code,
      };
}

/// `POST /auth/reset-password`
class ResetPasswordRequest {
  const ResetPasswordRequest({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  final String email;
  final String code;
  final String newPassword;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'email': email,
        'code': code,
        'new_password': newPassword,
      };
}

/// `POST /auth/change-password`
class ChangePasswordRequest {
  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'current_password': currentPassword,
        'new_password': newPassword,
      };
}
