import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ytu_assistant/core/network/localized_error.dart';
import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/features/jobs/data/models/applicant_model.dart';
import 'package:ytu_assistant/features/jobs/presentation/controllers/applicants_controller.dart';
import 'package:ytu_assistant/features/jobs/presentation/controllers/job_detail_controller.dart';
import 'package:ytu_assistant/features/jobs/presentation/widgets/applicant_tile.dart';
import 'package:ytu_assistant/features/jobs/presentation/widgets/empty_state.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';
import 'package:ytu_assistant/shared/widgets/skeleton_box.dart';

class ApplicantsScreen extends ConsumerWidget {
  const ApplicantsScreen({super.key, required this.jobId});

  final int jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final L10n l10n = L10n.of(context);
    final AsyncValue<List<ApplicantModel>> applicantsAsync =
        ref.watch(applicantsControllerProvider(jobId));
    final ApplicantSort sort = ref.watch(applicantSortProvider);
    final String? position =
        ref.watch(jobDetailControllerProvider(jobId)).valueOrNull?.position;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(l10n.applicantsScreenTitle),
            if (position != null)
              Text(
                position,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption,
              ),
          ],
        ),
        actions: <Widget>[
          PopupMenuButton<ApplicantSort>(
            tooltip: l10n.filterSortBy,
            icon: const Icon(Icons.sort),
            initialValue: sort,
            onSelected: (ApplicantSort value) =>
                ref.read(applicantSortProvider.notifier).state = value,
            itemBuilder: (BuildContext context) {
              final L10n l = L10n.of(context);
              return ApplicantSort.values
                  .map(
                    (ApplicantSort s) => PopupMenuItem<ApplicantSort>(
                      value: s,
                      child: Text(s.localizedLabel(l)),
                    ),
                  )
                  .toList();
            },
          ),
        ],
      ),
      body: applicantsAsync.when(
        loading: () => const _ApplicantsSkeleton(),
        error: (Object error, _) => EmptyState(
          icon: Icons.error_outline,
          title: l10n.couldNotLoadApplicants,
          subtitle: localizedApiError(l10n, error, overrides: <int, String>{
            403: l10n.noAccessToPosting,
            404: l10n.postingNotFound,
          }),
          actionLabel: l10n.actionRetry,
          onAction: () =>
              ref.read(applicantsControllerProvider(jobId).notifier).refresh(),
        ),
        data: (List<ApplicantModel> applicants) {
          if (applicants.isEmpty) {
            return EmptyState(
              icon: Icons.people_outline,
              title: l10n.noApplicantsYet,
              subtitle: l10n.applicantsWillAppear,
            );
          }
          final List<ApplicantModel> sorted = _sorted(applicants, sort);
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => ref
                .read(applicantsControllerProvider(jobId).notifier)
                .refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int index) {
                final ApplicantModel applicant = sorted[index];
                return ApplicantTile(
                  applicant: applicant,
                  onTap: () => context.push(
                    '/jobs/$jobId/applicants/${applicant.userId}',
                    extra: applicant,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  List<ApplicantModel> _sorted(
    List<ApplicantModel> applicants,
    ApplicantSort sort,
  ) {
    final List<ApplicantModel> list = <ApplicantModel>[...applicants];
    switch (sort) {
      case ApplicantSort.newest:
        list.sort((ApplicantModel a, ApplicantModel b) {
          final DateTime ad =
              a.appliedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final DateTime bd =
              b.appliedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bd.compareTo(ad);
        });
        break;
      case ApplicantSort.gpaDesc:
        list.sort((ApplicantModel a, ApplicantModel b) {
          final double ag = a.gpa ?? -1;
          final double bg = b.gpa ?? -1;
          return bg.compareTo(ag);
        });
        break;
    }
    return list;
  }
}

class _ApplicantsSkeleton extends StatelessWidget {
  const _ApplicantsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          children: <Widget>[
            SkeletonBox(width: 44, height: 44, borderRadius: 999),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SkeletonBox(width: 140, height: 16),
                  SizedBox(height: 8),
                  SkeletonBox(width: 100, height: 12),
                ],
              ),
            ),
            SizedBox(width: 12),
            SkeletonBox(width: 64, height: 24, borderRadius: 999),
          ],
        ),
      ),
    );
  }
}
