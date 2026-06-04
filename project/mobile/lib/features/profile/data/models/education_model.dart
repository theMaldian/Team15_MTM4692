/// An education entry (`details.educations` row / educations CRUD):
/// `{ id, university, department, gpa, start_date, end_date }`.
class EducationModel {
  const EducationModel({
    required this.id,
    this.university,
    this.department,
    this.gpa,
    this.startDate,
    this.endDate,
  });

  final int id;
  final String? university;
  final String? department;
  final double? gpa;
  final DateTime? startDate;
  final DateTime? endDate;

  bool get isOngoing => endDate == null;

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      id: (json['id'] as num).toInt(),
      university: json['university'] as String?,
      department: json['department'] as String?,
      gpa: _toDoubleOrNull(json['gpa']),
      startDate: _parseDate(json['start_date']),
      endDate: _parseDate(json['end_date']),
    );
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
