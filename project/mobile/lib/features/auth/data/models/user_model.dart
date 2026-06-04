import 'package:ytu_assistant/features/auth/domain/user_role.dart';

/// User DTO returned by `/auth/login` (minimal subset) and `/profile`
/// (full subset). All fields are optional except [userId], [role] and [email]
/// because the login response only ships a subset.
///
/// JSON keys mirror the backend exactly (snake_case).
class UserModel {
  const UserModel({
    required this.userId,
    required this.role,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.university,
    this.faculty,
    this.department,
    this.isVerified,
    this.createdAt,
    this.updatedAt,
  });

  final int userId;
  final UserRole role;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? university;
  final String? faculty;
  final String? department;
  final bool? isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get fullName {
    final String first = (firstName ?? '').trim();
    final String last = (lastName ?? '').trim();
    final String joined = '$first $last'.trim();
    return joined.isEmpty ? email : joined;
  }

  String get initials {
    final String first = (firstName ?? '').trim();
    final String last = (lastName ?? '').trim();
    final String f = first.isNotEmpty ? first[0] : '';
    final String l = last.isNotEmpty ? last[0] : '';
    final String combined = ('$f$l').toUpperCase();
    if (combined.isNotEmpty) {
      return combined;
    }
    return email.isNotEmpty ? email[0].toUpperCase() : '?';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: (json['user_id'] as num).toInt(),
      role: UserRole.fromString(json['role'] as String),
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      university: json['university'] as String?,
      faculty: json['faculty'] as String?,
      department: json['department'] as String?,
      isVerified: json['is_verified'] is bool
          ? json['is_verified'] as bool
          : json['is_verified'] is num
              ? (json['is_verified'] as num) != 0
              : null,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'user_id': userId,
      'role': role.wireValue,
      'email': email,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (phone != null) 'phone': phone,
      if (university != null) 'university': university,
      if (faculty != null) 'faculty': faculty,
      if (department != null) 'department': department,
      if (isVerified != null) 'is_verified': isVerified,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  UserModel copyWith({
    int? userId,
    UserRole? role,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? university,
    String? faculty,
    String? department,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      role: role ?? this.role,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      university: university ?? this.university,
      faculty: faculty ?? this.faculty,
      department: department ?? this.department,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
