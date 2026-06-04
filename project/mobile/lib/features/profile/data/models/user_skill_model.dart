/// A skill linked to the current user (`details.skills` row in `GET /profile`):
/// `{ skill_id, skill_name }`.
class UserSkillModel {
  const UserSkillModel({required this.skillId, required this.skillName});

  final int skillId;
  final String skillName;

  factory UserSkillModel.fromJson(Map<String, dynamic> json) {
    return UserSkillModel(
      skillId: (json['skill_id'] as num).toInt(),
      skillName: (json['skill_name'] as String?) ?? '',
    );
  }
}
