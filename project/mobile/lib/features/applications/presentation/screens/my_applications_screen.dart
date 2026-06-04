import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ytu_assistant/core/network/localized_error.dart';
import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/features/applications/data/models/application_model.dart';
import 'package:ytu_assistant/features/applications/presentation/controllers/my_applications_controller.dart';
import 'package:ytu_assistant/features/applications/presentation/controllers/withdraw_controller.dart';
import 'package:ytu_assistant/features/applications/presentation/widgets/application_card.dart';
import 'package:ytu_assistant/features/jobs/presentation/widgets/empty_state.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';
import 'package:ytu_assistant/shared/widgets/app_snack_bar.dart';
import 'package:ytu_assistant/shared/widgets/skeleton_box.dart';
import 'package:ytu_assistant/shared/widgets/ytu_logo.dart';

/// Student-only: the signed-in student's applications (`/my-applications`).
class MyApplicationsScreen extends ConsumerWidget {
  const MyApplicationsScreen({super.key});

  Future<void> _confirmWithdraw(
    BuildContext context,
    WidgetRef ref,
    L10n l10n,
    ApplicationModel app,
  ) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.withdrawConfirmTitle),
        content: Text(l10n.withdrawConfirmBody(app.position)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.withdrawAction),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) {
      return;
    }
    try {
      await ref
          .read(withdrawControllerProvider.notifier)
          .withdraw(app.applicationId, jobId: app.jobId);
      if (context.mounted) {
        AppSnackBar.success(context, l10n.withdrawSuccess);
      }
    } catch (error) {
      if (context.mounted) {
        AppSnackBar.error(context, localizedApiError(l10n, error));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final L10n l10n = L10n.of(context);
    final AsyncValue<List<ApplicationModel>> async =
        ref.watch(myApplicationsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myApplicationsTitle)),
      body: async.when(
        skipLoadingOnReload: true,
        loading: () => const _ApplicationsSkeleton(),
        error: (Object error, _) => EmptyState(
          icon: Icons.cloud_off_outlined,
          title: l10n.applicationsErrorTitle,
          subtitle: localizedApiError(l10n, error),
          actionLabel: l10n.actionRetry,
          onAction: () =>
              ref.read(myApplicationsControllerProvider.notifier).refresh(),
        ),
        data: (List<ApplicationModel> apps) {
          if (apps.isEmpty) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () =>
                  ref.read(myApplicationsControllerProvider.notifier).refresh(),
              child: ListView(
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height * 0.16),
                  Center(
                    child: Column(
                      children: <Widget>[
                        const YtuLogo(
                          size: 64,
                          starColor: AppColors.border,
                          ringColor: AppColors.border,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.applicationsEmptyTitle,
                          style: AppTextStyles.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            l10n.applicationsEmptySubtitle,
                            style: AppTextStyles.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () =>
                ref.read(myApplicationsControllerProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: apps.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int index) {
                final ApplicationModel app = apps[index];
                return ApplicationCard(
                  application: app,
                  onTap: () => context.push('/jobs/${app.jobId}'),
                  onWithdraw: app.isPending
                      ? () => _confirmWithdraw(context, ref, l10n, app)
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ApplicationsSkeleton extends StatelessWidget {
  const _ApplicationsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                SkeletonBox(width: 180, height: 18),
                Spacer(),
                SkeletonBox(width: 70, height: 22, borderRadius: 999),
              ],
            ),
            SizedBox(height: 10),
            SkeletonBox(width: 130, height: 12),
            SizedBox(height: 10),
            SkeletonBox(width: 150, height: 12),
          ],
        ),
      ),
    );
  }
}
