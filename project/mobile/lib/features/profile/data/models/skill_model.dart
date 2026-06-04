/// Catalog skill from `GET /skills` (`{ skill_id, skill_name }`).
class SkillModel {
  const SkillModel({required this.skillId, required this.skillName});

  final int skillId;
  final String skillName;

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      skillId: (json['skill_id'] as num).toInt(),
      skillName: (json['skill_name'] as String?) ?? '',
    );
  }
}
