import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/core/network/localized_error.dart';
import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/features/profile/data/models/language_model.dart';
import 'package:ytu_assistant/features/profile/data/models/profile_model.dart';
import 'package:ytu_assistant/features/profile/data/models/user_language_model.dart';
import 'package:ytu_assistant/features/profile/domain/language_level.dart';
import 'package:ytu_assistant/features/profile/presentation/controllers/catalog_controller.dart';
import 'package:ytu_assistant/features/profile/presentation/controllers/languages_controller.dart';
import 'package:ytu_assistant/features/profile/presentation/controllers/profile_controller.dart';
import 'package:ytu_assistant/features/profile/presentation/widgets/language_chip.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';
import 'package:ytu_assistant/shared/widgets/app_snack_bar.dart';
import 'package:ytu_assistant/shared/widgets/app_text_field.dart';

class ManageLanguagesScreen extends ConsumerStatefulWidget {
  const ManageLanguagesScreen({super.key});

  @override
  ConsumerState<ManageLanguagesScreen> createState() =>
      _ManageLanguagesScreenState();
}

class _ManageLanguagesScreenState
    extends ConsumerState<ManageLanguagesScreen> {
  String _query = '';

  Future<LanguageLevel?> _pickLevel(L10n l10n) {
    return showModalBottomSheet<LanguageLevel>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 16),
            Text(l10n.selectLevel, style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            ...LanguageLevel.values.map(
              (LanguageLevel lvl) => ListTile(
                title: Text(lvl.localizedLabel(l10n)),
                onTap: () => Navigator.of(ctx).pop(lvl),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _add(LanguageModel language) async {
    final L10n l10n = L10n.of(context);
    final LanguageLevel? level = await _pickLevel(l10n);
    if (level == null || !mounted) {
      return;
    }
    try {
      await ref.read(languagesControllerProvider.notifier).add(
            languageId: language.languageId,
            level: level,
          );
    } catch (error) {
      if (mounted) {
        AppSnackBar.error(context, localizedApiError(l10n, error));
      }
    }
  }

  Future<void> _changeLevel(UserLanguageModel language) async {
    final L10n l10n = L10n.of(context);
    final LanguageLevel? level = await _pickLevel(l10n);
    if (level == null || !mounted) {
      return;
    }
    try {
      await ref
          .read(languagesControllerProvider.notifier)
          .changeLevel(language.languageId, level);
    } catch (error) {
      if (mounted) {
        AppSnackBar.error(context, localizedApiError(l10n, error));
      }
    }
  }

  Future<void> _remove(int languageId) async {
    final L10n l10n = L10n.of(context);
    try {
      await ref.read(languagesControllerProvider.notifier).remove(languageId);
    } catch (error) {
      if (mounted) {
        AppSnackBar.error(context, localizedApiError(l10n, error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final ProfileModel? profile =
        ref.watch(profileControllerProvider).valueOrNull;
    final AsyncValue<CatalogData> catalogAsync =
        ref.watch(catalogControllerProvider);

    final Set<int> selectedIds = (profile?.languages ?? <UserLanguageModel>[])
        .map((UserLanguageModel l) => l.languageId)
        .toSet();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.manageLanguagesTitle)),
      body: Column(
        children: <Widget>[
          if (profile != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: profile.languages.isEmpty
                    ? Text(l10n.noLanguagesYet, style: AppTextStyles.bodyMedium)
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profile.languages
                            .map((UserLanguageModel lng) => LanguageChip(
                                  language: lng,
                                  onTap: () => _changeLevel(lng),
                                  onRemoved: () => _remove(lng.languageId),
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
              label: l10n.searchLanguagesHint,
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
                final List<LanguageModel> available =
                    catalog.languages.where((LanguageModel l) {
                  final bool notAdded = !selectedIds.contains(l.languageId);
                  final bool matches = _query.isEmpty ||
                      l.languageName.toLowerCase().contains(_query.toLowerCase());
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
                    final LanguageModel l = available[index];
                    return ListTile(
                      title: Text(l.languageName),
                      trailing: const Icon(Icons.add_circle_outline,
                          color: AppColors.primary),
                      onTap: () => _add(l),
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
