import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/features/jobs/domain/job_category.dart';
import 'package:ytu_assistant/features/jobs/presentation/controllers/active_jobs_controller.dart';
import 'package:ytu_assistant/features/jobs/presentation/job_category_l10n.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';
import 'package:ytu_assistant/shared/widgets/app_text_field.dart';
import 'package:ytu_assistant/shared/widgets/primary_button.dart';
import 'package:ytu_assistant/shared/widgets/secondary_button.dart';

/// Horizontal bar showing the active filters as removable chips. Hidden when
/// no filters are applied.
class JobFilterBar extends ConsumerWidget {
  const JobFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final L10n l10n = L10n.of(context);
    final JobFilterState filter = ref.watch(jobFilterProvider);
    if (!filter.isActive) {
      return const SizedBox.shrink();
    }

    final List<Widget> chips = <Widget>[
      for (final JobCategory c in filter.categories)
        _chip(
          label: c.localizedLabel(l10n),
          onRemoved: () {
            final Set<JobCategory> next = <JobCategory>{...filter.categories}
              ..remove(c);
            ref.read(jobFilterProvider.notifier).state =
                filter.copyWith(categories: next);
          },
        ),
      if (filter.department.trim().isNotEmpty)
        _chip(
          label: l10n.filterDeptChip(filter.department.trim()),
          onRemoved: () {
            ref.read(jobFilterProvider.notifier).state =
                filter.copyWith(department: '');
          },
        ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Wrap(spacing: 8, runSpacing: 8, children: chips),
    );
  }

  Widget _chip({required String label, required VoidCallback onRemoved}) {
    return Chip(
      label: Text(label),
      onDeleted: onRemoved,
      deleteIcon: const Icon(Icons.close, size: 16),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

/// Bottom sheet for editing the active-jobs filter (category multi-select,
/// department text, sort).
class JobFilterSheet extends ConsumerStatefulWidget {
  const JobFilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const JobFilterSheet(),
    );
  }

  @override
  ConsumerState<JobFilterSheet> createState() => _JobFilterSheetState();
}

class _JobFilterSheetState extends ConsumerState<JobFilterSheet> {
  late Set<JobCategory> _categories;
  late TextEditingController _department;
  late JobSort _sort;

  @override
  void initState() {
    super.initState();
    final JobFilterState filter = ref.read(jobFilterProvider);
    _categories = <JobCategory>{...filter.categories};
    _department = TextEditingController(text: filter.department);
    _sort = filter.sort;
  }

  @override
  void dispose() {
    _department.dispose();
    super.dispose();
  }

  void _apply() {
    ref.read(jobFilterProvider.notifier).state = JobFilterState(
      categories: _categories,
      department: _department.text.trim(),
      sort: _sort,
    );
    Navigator.of(context).pop();
  }

  void _reset() {
    setState(() {
      _categories = <JobCategory>{};
      _department.clear();
      _sort = JobSort.newest;
    });
  }

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.filterSheetTitle, style: AppTextStyles.titleLarge),
          const SizedBox(height: 20),
          Text(l10n.filterCategory, style: AppTextStyles.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final JobCategory c in JobCategory.values)
                FilterChip(
                  label: Text(c.localizedLabel(l10n)),
                  selected: _categories.contains(c),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _categories.add(c);
                      } else {
                        _categories.remove(c);
                      }
                    });
                  },
                  selectedColor: AppColors.primary,
                  checkmarkColor: AppColors.textOnPrimary,
                  labelStyle: AppTextStyles.caption.copyWith(
                    color: _categories.contains(c)
                        ? AppColors.textOnPrimary
                        : AppColors.textPrimary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(l10n.fieldDepartment, style: AppTextStyles.label),
          const SizedBox(height: 8),
          AppTextField(
            label: l10n.fieldDepartment,
            hint: l10n.filterDeptHint,
            controller: _department,
            prefixIcon: Icons.account_balance_outlined,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 20),
          Text(l10n.filterSortBy, style: AppTextStyles.label),
          const SizedBox(height: 8),
          DropdownButtonFormField<JobSort>(
            initialValue: _sort,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.sort, size: 20),
            ),
            items: JobSort.values
                .map(
                  (JobSort s) => DropdownMenuItem<JobSort>(
                    value: s,
                    child: Text(s.localizedLabel(l10n)),
                  ),
                )
                .toList(),
            onChanged: (JobSort? value) =>
                setState(() => _sort = value ?? JobSort.newest),
          ),
          const SizedBox(height: 24),
          Row(
            children: <Widget>[
              Expanded(
                child: SecondaryButton(label: l10n.filterReset, onPressed: _reset),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(label: l10n.filterApply, onPressed: _apply),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
