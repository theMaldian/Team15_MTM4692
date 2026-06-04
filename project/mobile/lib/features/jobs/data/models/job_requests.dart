import 'package:ytu_assistant/features/jobs/domain/job_category.dart';

/// `POST /jobs` — all fields required. `deadline` is an ISO date string
/// (the backend casts to SQL `Date`). `is_active` is NOT sent (defaults true).
class CreateJobRequest {
  const CreateJobRequest({
    required this.jobCategory,
    required this.departmentName,
    required this.position,
    required this.description,
    required this.deadline,
  });

  final JobCategory jobCategory;
  final String departmentName;
  final String position;
  final String description;
  final DateTime deadline;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'job_category': jobCategory.wireValue,
        'department_name': departmentName,
        'position': position,
        'description': description,
        'deadline': _isoDate(deadline),
      };
}

/// `PUT /jobs/:id` — any subset (at least one). Only non-null fields are sent.
class UpdateJobRequest {
  const UpdateJobRequest({
    this.jobCategory,
    this.departmentName,
    this.position,
    this.description,
    this.deadline,
  });

  final JobCategory? jobCategory;
  final String? departmentName;
  final String? position;
  final String? description;
  final DateTime? deadline;

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (jobCategory != null) 'job_category': jobCategory!.wireValue,
        if (departmentName != null) 'department_name': departmentName,
        if (position != null) 'position': position,
        if (description != null) 'description': description,
        if (deadline != null) 'deadline': _isoDate(deadline!),
      };

  bool get isEmpty => toJson().isEmpty;
}

/// Serialize a date as `yyyy-MM-dd` (date-only, matching the backend column).
String _isoDate(DateTime date) {
  final DateTime d = date.toLocal();
  final String y = d.year.toString().padLeft(4, '0');
  final String m = d.month.toString().padLeft(2, '0');
  final String day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}
