import 'package:ytu_assistant/features/jobs/domain/application_status.dart';

/// Applicant row from `GET /jobs/:id/applicants`.
///
/// Joins `Users` + `Student_Profile` fields. JSON keys mirror the backend.
class ApplicantModel {
  const ApplicantModel({
    required this.applicationId,
    required this.userId,
    required this.status,
    this.appliedAt,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.university,
    this.faculty,
    this.department,
    this.degreeLevel,
    this.classYear,
    this.gpa,
    this.expectedGraduationDate,
  });

  final int applicationId;
  final int userId;
  final ApplicationStatus status;
  final DateTime? appliedAt;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? university;
  final String? faculty;
  final String? department;
  final String? degreeLevel;
  final int? classYear;
  final double? gpa;
  final DateTime? expectedGraduationDate;

  String get fullName {
    final String name = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    return name.isEmpty ? (email ?? 'Applicant #$userId') : name;
  }

  String get initials {
    final String f = (firstName ?? '').trim();
    final String l = (lastName ?? '').trim();
    final String combined =
        '${f.isNotEmpty ? f[0] : ''}${l.isNotEmpty ? l[0] : ''}'.toUpperCase();
    if (combined.isNotEmpty) {
      return combined;
    }
    final String e = (email ?? '').trim();
    return e.isNotEmpty ? e[0].toUpperCase() : '?';
  }

  factory ApplicantModel.fromJson(Map<String, dynamic> json) {
    return ApplicantModel(
      applicationId: (json['application_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      status: ApplicationStatus.tryFromString(json['status'] as String?) ??
          ApplicationStatus.pending,
      appliedAt: _parseDate(json['applied_at']),
      email: json['email'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      university: json['university'] as String?,
      faculty: json['faculty'] as String?,
      department: json['department'] as String?,
      degreeLevel: json['degree_level'] as String?,
      classYear: _toIntOrNull(json['class_year']),
      gpa: _toDoubleOrNull(json['gpa']),
      expectedGraduationDate: _parseDate(json['expected_graduation_date']),
    );
  }

  static int? _toIntOrNull(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString());
  }

  static double? _toDoubleOrNull(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
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
