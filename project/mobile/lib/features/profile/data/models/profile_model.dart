import 'package:ytu_assistant/features/auth/data/models/user_model.dart';
import 'package:ytu_assistant/features/auth/domain/user_role.dart';
import 'package:ytu_assistant/features/profile/data/models/education_model.dart';
import 'package:ytu_assistant/features/profile/data/models/experience_model.dart';
import 'package:ytu_assistant/features/profile/data/models/user_language_model.dart';
import 'package:ytu_assistant/features/profile/data/models/user_skill_model.dart';

/// Student-only profile fields (`profile` object when role = student).
class StudentProfile {
  const StudentProfile({
    this.degreeLevel,
    this.classYear,
    this.gpa,
    this.expectedGraduationDate,
  });

  final String? degreeLevel;
  final int? classYear;
  final double? gpa;
  final DateTime? expectedGraduationDate;

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      degreeLevel: json['degree_level'] as String?,
      classYear: _toIntOrNull(json['class_year']),
      gpa: _toDoubleOrNull(json['gpa']),
      expectedGraduationDate: _parseDate(json['expected_graduation_date']),
    );
  }
}

/// Professor-only profile fields (`profile` object when role = professor).
class ProfessorProfile {
  const ProfessorProfile({this.academicTitle});

  final String? academicTitle;

  factory ProfessorProfile.fromJson(Map<String, dynamic> json) {
    return ProfessorProfile(academicTitle: json['academic_title'] as String?);
  }
}

/// The full `GET /profile` shape: the user, the role-specific profile, and the
/// CV detail collections.
class ProfileModel {
  const ProfileModel({
    required this.user,
    this.student,
    this.professor,
    this.skills = const <UserSkillModel>[],
    this.languages = const <UserLanguageModel>[],
    this.experiences = const <ExperienceModel>[],
    this.educations = const <EducationModel>[],
  });

  final UserModel user;
  final StudentProfile? student;
  final ProfessorProfile? professor;
  final List<UserSkillModel> skills;
  final List<UserLanguageModel> languages;
  final List<ExperienceModel> experiences;
  final List<EducationModel> educations;

  bool get isStudent => user.role == UserRole.student;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final UserModel user = UserModel.fromJson(_castMap(json['user']));

    StudentProfile? student;
    ProfessorProfile? professor;
    final dynamic profileRaw = json['profile'];
    if (profileRaw is Map) {
      final Map<String, dynamic> pj = _castMap(profileRaw);
      if (user.role == UserRole.student) {
        student = StudentProfile.fromJson(pj);
      } else {
        professor = ProfessorProfile.fromJson(pj);
      }
    }

    final dynamic detailsRaw = json['details'];
    final Map<String, dynamic> details =
        detailsRaw is Map ? _castMap(detailsRaw) : <String, dynamic>{};

    return ProfileModel(
      user: user,
      student: student,
      professor: professor,
      skills: _list<UserSkillModel>(details['skills'], UserSkillModel.fromJson),
      languages: _list<UserLanguageModel>(
          details['languages'], UserLanguageModel.fromJson),
      experiences: _list<ExperienceModel>(
          details['experiences'], ExperienceModel.fromJson),
      educations: _list<EducationModel>(
          details['educations'], EducationModel.fromJson),
    );
  }

  static List<T> _list<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw is! List) {
      return <T>[];
    }
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> e) => fromJson(_castMap(e)))
        .toList();
  }

  static Map<String, dynamic> _castMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return raw.map((Object? key, Object? value) =>
          MapEntry<String, dynamic>(key.toString(), value));
    }
    return <String, dynamic>{};
  }
}

int? _toIntOrNull(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value.toString());
}

double? _toDoubleOrNull(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value.toString());
}

DateTime? _parseDate(dynamic value) {
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
