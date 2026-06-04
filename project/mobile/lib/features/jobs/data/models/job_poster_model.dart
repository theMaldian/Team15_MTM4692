/// Professor (job poster) info.
///
/// Jobs endpoints return these as FLAT fields (`professor_id`,
/// `professor_first_name`, `professor_last_name`, `professor_email`) — there is
/// NO nested object and NO academic title / faculty on the jobs payloads
/// (see BACKEND_API.md). [fromJobJson] extracts them when present.
class JobPosterModel {
  const JobPosterModel({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
  });

  final int id;
  final String? firstName;
  final String? lastName;
  final String? email;

  String get fullName {
    final String name = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    return name.isEmpty ? (email ?? 'Unknown') : name;
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

  /// Builds a poster from the flat `professor_*` fields on a job payload.
  /// Returns null when no professor id is present (e.g. `/jobs/my`).
  static JobPosterModel? fromJobJson(Map<String, dynamic> json) {
    final dynamic rawId = json['professor_id'];
    if (rawId == null) {
      return null;
    }
    return JobPosterModel(
      id: (rawId as num).toInt(),
      firstName: json['professor_first_name'] as String?,
      lastName: json['professor_last_name'] as String?,
      email: json['professor_email'] as String?,
    );
  }
}
