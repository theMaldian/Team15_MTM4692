import 'package:flutter/material.dart';

/// Job categories. The backend stores `job_category` as free-text
/// NVARCHAR(100) (no DB constraint), so [fromString] maps the four known
/// canonical values and falls back to [other] for anything else — the raw
/// string is preserved on [JobModel] for display.
enum JobCategory {
  courseAssistant,
  labAssistant,
  researchAssistant,
  other;

  /// Wire value sent to / received from the backend.
  String get wireValue {
    switch (this) {
      case JobCategory.courseAssistant:
        return 'course_assistant';
      case JobCategory.labAssistant:
        return 'lab_assistant';
      case JobCategory.researchAssistant:
        return 'research_assistant';
      case JobCategory.other:
        return 'other';
    }
  }

  String get label {
    switch (this) {
      case JobCategory.courseAssistant:
        return 'Course Assistant';
      case JobCategory.labAssistant:
        return 'Lab Assistant';
      case JobCategory.researchAssistant:
        return 'Research Assistant';
      case JobCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case JobCategory.courseAssistant:
        return Icons.menu_book;
      case JobCategory.labAssistant:
        return Icons.science;
      case JobCategory.researchAssistant:
        return Icons.biotech;
      case JobCategory.other:
        return Icons.work_outline;
    }
  }

  /// Maps a backend string to a category, case/separator-insensitively.
  /// Unknown values resolve to [other].
  static JobCategory fromString(String? value) {
    final String normalized =
        (value ?? '').trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
    switch (normalized) {
      case 'course_assistant':
        return JobCategory.courseAssistant;
      case 'lab_assistant':
        return JobCategory.labAssistant;
      case 'research_assistant':
        return JobCategory.researchAssistant;
      default:
        return JobCategory.other;
    }
  }
}
