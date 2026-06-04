import 'package:ytu_assistant/features/jobs/data/models/job_poster_model.dart';
import 'package:ytu_assistant/features/jobs/domain/application_status.dart';
import 'package:ytu_assistant/features/jobs/domain/job_category.dart';

/// Job DTO. A single superset model covering the three backend shapes:
/// `/jobs/active` (student feed), `/jobs/my` (professor list with counts),
/// and `/jobs/:id` (detail with `my_application_*`).
///
/// JSON keys mirror the backend exactly. Fields absent in a given shape are
/// left null.
class JobModel {
  const JobModel({
    required this.jobId,
    this.userId,
    required this.jobCategoryRaw,
    required this.departmentName,
    required this.position,
    required this.description,
    required this.deadline,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.poster,
    this.applicationCount,
    this.pendingCount,
    this.approvedCount,
    this.rejectedCount,
    this.myApplicationId,
    this.myApplicationStatus,
  });

  final int jobId;

  /// Poster's user id. From `user_id` (create/detail) or `professor_id`
  /// (active feed). Null on `/jobs/my` (it's implicitly the current professor).
  final int? userId;

  /// Raw category string from the backend (free-text).
  final String jobCategoryRaw;

  final String departmentName;
  final String position;
  final String description;
  final DateTime deadline;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Professor info — only present on `/jobs/active` and `/jobs/:id`.
  final JobPosterModel? poster;

  // `/jobs/my` aggregate counts.
  final int? applicationCount;
  final int? pendingCount;
  final int? approvedCount;
  final int? rejectedCount;

  // `/jobs/:id` per-current-user application info.
  final int? myApplicationId;
  final ApplicationStatus? myApplicationStatus;

  /// Derived category enum (for icon / grouping).
  JobCategory get category => JobCategory.fromString(jobCategoryRaw);

  /// Human-readable category label that preserves unknown free-text values.
  String get categoryLabel {
    final JobCategory c = category;
    if (c != JobCategory.other) {
      return c.label;
    }
    final String raw = jobCategoryRaw.trim();
    if (raw.isEmpty || raw.toLowerCase() == 'other') {
      return 'Other';
    }
    return raw
        .split(RegExp(r'[\s_-]+'))
        .where((String w) => w.isNotEmpty)
        .map((String w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  /// True only when the backend reported an application for the current user
  /// (detail endpoint). The active feed cannot answer this.
  bool get hasApplied => myApplicationId != null;

  /// True when the deadline (date-only) is before today.
  bool get isExpired {
    final DateTime d =
        DateTime(deadline.year, deadline.month, deadline.day);
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    return d.isBefore(today);
  }

  /// Open for applications: active and not past deadline.
  bool get isOpen => isActive && !isExpired;

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      jobId: (json['job_id'] as num).toInt(),
      userId: _toIntOrNull(json['user_id'] ?? json['professor_id']),
      jobCategoryRaw: (json['job_category'] as String?) ?? '',
      departmentName: (json['department_name'] as String?) ?? '',
      position: (json['position'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      deadline: _parseDate(json['deadline']) ?? DateTime.now(),
      isActive: _toBool(json['is_active'], defaultValue: true),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      poster: JobPosterModel.fromJobJson(json),
      applicationCount: _toIntOrNull(json['application_count']),
      pendingCount: _toIntOrNull(json['pending_count']),
      approvedCount: _toIntOrNull(json['approved_count']),
      rejectedCount: _toIntOrNull(json['rejected_count']),
      myApplicationId: _toIntOrNull(json['my_application_id']),
      myApplicationStatus:
          ApplicationStatus.tryFromString(json['my_application_status'] as String?),
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
