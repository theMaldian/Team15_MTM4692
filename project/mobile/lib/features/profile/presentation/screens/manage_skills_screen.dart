import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/core/network/localized_error.dart';
import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/features/profile/data/models/profile_model.dart';
import 'package:ytu_assistant/features/profile/data/models/skill_model.dart';
import 'package:ytu_assistant/features/profile/data/models/user_skill_model.dart';
import 'package:ytu_assistant/features/profile/presentation/controllers/catalog_controller.dart';
import 'package:ytu_assistant/features/profile/presentation/controllers/profile_controller.dart';
import 'package:ytu_assistant/features/profile/presentation/controllers/skills_controller.dart';
import 'package:ytu_assistant/features/profile/presentation/widgets/skill_chip.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';
import 'package:ytu_assistant/shared/widgets/app_snack_bar.dart';
import 'package:ytu_assistant/shared/widgets/app_text_field.dart';

class ManageSkillsScreen extends ConsumerStatefulWidget {
  const ManageSkillsScreen({super.key});

  @override
  ConsumerState<ManageSkillsScreen> createState() => _ManageSkillsScreenState();
}

class _ManageSkillsScreenState extends ConsumerState<ManageSkillsScreen> {
  String _query = '';

  Future<void> _add(SkillModel skill) async {
    final L10n l10n = L10n.of(context);
    try {
      await ref.read(skillsControllerProvider.notifier).add(skillId: skill.skillId);
    } catch (error) {
      if (mounted) {
        AppSnackBar.error(context, localizedApiError(l10n, error));
      }
    }
  }

  Future<void> _remove(int skillId) async {
    final L10n l10n = L10n.of(context);
    try {
      await ref.read(skillsControllerProvider.notifier).remove(skillId);
    } catch (error) {
      if (mounted) {
        AppSnackBar.error(context, localizedApiError(l10n, error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final ProfileModel? profile = ref.watch(profileControllerProvider).valueOrNull;
    final AsyncValue<CatalogData> catalogAsync =
        ref.watch(catalogControllerProvider);

    final Set<int> selectedIds = (profile?.skills ?? <UserSkillModel>[])
        .map((UserSkillModel s) => s.skillId)
        .toSet();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.manageSkillsTitle)),
      body: Column(
        children: <Widget>[
          // Selected skills.
          if (profile != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: profile.skills.isEmpty
                    ? Text(l10n.noSkillsYet, style: AppTextStyles.bodyMedium)
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profile.skills
                            .map((UserSkillModel s) => SkillChip(
                                  label: s.skillName,
                                  onRemoved: () => _remove(s.skillId),
                                ))
                            .toList(),
                      ),
              ),
            ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Divider(height: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppTextField(
              label: l10n.searchSkillsHint,
              prefixIcon: Icons.search,
              onChanged: (String v) => setState(() => _query = v.trim()),
            ),
          ),
          Expanded(
            child: catalogAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, _) => Center(
                child: Text(localizedApiError(l10n, error),
                    style: AppTextStyles.bodyMedium),
              ),
              data: (CatalogData catalog) {
                final List<SkillModel> available = catalog.skills.where((SkillModel s) {
                  final bool notAdded = !selectedIds.contains(s.skillId);
                  final bool matches = _query.isEmpty ||
                      s.skillName.toLowerCase().contains(_query.toLowerCase());
                  return notAdded && matches;
                }).toList();

                if (available.isEmpty) {
                  return Center(
                    child: Text(l10n.skillsCatalogEmpty,
                        style: AppTextStyles.bodyMedium),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: available.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    final SkillModel s = available[index];
                    return ListTile(
                      title: Text(s.skillName),
                      trailing: const Icon(Icons.add_circle_outline,
                          color: AppColors.primary),
                      onTap: () => _add(s),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
