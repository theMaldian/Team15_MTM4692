/// A work-experience entry (`details.experiences` row / experiences CRUD):
/// `{ id, company_name, position, description, start_date, end_date }`.
class ExperienceModel {
  const ExperienceModel({
    required this.id,
    this.companyName,
    this.position,
    this.description,
    this.startDate,
    this.endDate,
  });

  final int id;
  final String? companyName;
  final String? position;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;

  /// No end date → still ongoing.
  bool get isOngoing => endDate == null;

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: (json['id'] as num).toInt(),
      companyName: json['company_name'] as String?,
      position: json['position'] as String?,
      description: json['description'] as String?,
      startDate: _parseDate(json['start_date']),
      endDate: _parseDate(json['end_date']),
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
