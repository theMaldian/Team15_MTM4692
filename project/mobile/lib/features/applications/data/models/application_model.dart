import 'package:ytu_assistant/features/jobs/domain/application_status.dart';

/// A student's own application row from `GET /applications/my`.
///
/// Joins the application with its job + professor info. JSON keys mirror the
/// backend exactly (see BACKEND_API.md → Applications).
class ApplicationModel {
  const ApplicationModel({
    required this.applicationId,
    required this.status,
    this.appliedAt,
    required this.jobId,
    this.jobCategory,
    this.departmentName,
    required this.position,
    this.description,
    this.deadline,
    this.isActive = true,
    this.jobCreatedAt,
    this.professorId,
    this.professorFirstName,
    this.professorLastName,
    this.professorEmail,
  });

  final int applicationId;
  final ApplicationStatus status;
  final DateTime? appliedAt;

  final int jobId;
  final String? jobCategory;
  final String? departmentName;
  final String position;
  final String? description;
  final DateTime? deadline;
  final bool isActive;
  final DateTime? jobCreatedAt;

  final int? professorId;
  final String? professorFirstName;
  final String? professorLastName;
  final String? professorEmail;

  /// Only `pending` applications can be withdrawn by the student.
  bool get isPending => status == ApplicationStatus.pending;

  String get professorName {
    final String name =
        '${professorFirstName ?? ''} ${professorLastName ?? ''}'.trim();
    return name.isEmpty ? (professorEmail ?? '') : name;
  }

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      applicationId: (json['application_id'] as num).toInt(),
      status: ApplicationStatus.tryFromString(json['status'] as String?) ??
          ApplicationStatus.pending,
      appliedAt: _parseDate(json['applied_at']),
      jobId: (json['job_id'] as num).toInt(),
      jobCategory: json['job_category'] as String?,
      departmentName: json['department_name'] as String?,
      position: (json['position'] as String?) ?? '',
      description: json['description'] as String?,
      deadline: _parseDate(json['deadline']),
      isActive: _toBool(json['is_active'], defaultValue: true),
      jobCreatedAt: _parseDate(json['job_created_at']),
      professorId: _toIntOrNull(json['professor_id']),
      professorFirstName: json['professor_first_name'] as String?,
      professorLastName: json['professor_last_name'] as String?,
      professorEmail: json['professor_email'] as String?,
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

  static bool _toBool(dynamic value, {required bool defaultValue}) {
    if (value == null) {
      return defaultValue;
    }
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    final String s = value.toString().toLowerCase();
    return s == 'true' || s == '1';
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
