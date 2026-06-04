import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ytu_assistant/core/network/localized_error.dart';
import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/features/applications/presentation/application_status_l10n.dart';
import 'package:ytu_assistant/features/applications/presentation/controllers/applicant_status_controller.dart';
import 'package:ytu_assistant/features/applications/presentation/widgets/status_timeline.dart';
import 'package:ytu_assistant/features/applications/presentation/widgets/status_update_sheet.dart';
import 'package:ytu_assistant/features/jobs/data/models/applicant_model.dart';
import 'package:ytu_assistant/features/jobs/domain/application_status.dart';
import 'package:ytu_assistant/features/jobs/presentation/controllers/applicants_controller.dart';
import 'package:ytu_assistant/features/jobs/presentation/widgets/empty_state.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';
import 'package:ytu_assistant/shared/widgets/app_snack_bar.dart';
import 'package:ytu_assistant/shared/widgets/primary_button.dart';

/// Professor-only: one applicant's full info + a status-update action.
/// The applicant is passed via go_router `extra`; if absent (deep link /
/// refresh) it is resolved from the cached applicants list for the job.
class ApplicantDetailScreen extends ConsumerStatefulWidget {
  const ApplicantDetailScreen({
    super.key,
    required this.jobId,
    required this.userId,
    this.applicant,
  });

  final int jobId;
  final int userId;
  final ApplicantModel? applicant;

  @override
  ConsumerState<ApplicantDetailScreen> createState() =>
      _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState
    extends ConsumerState<ApplicantDetailScreen> {
  bool _busy = false;

  ApplicantModel? _resolve() {
    if (widget.applicant != null) {
      return widget.applicant;
    }
    final List<ApplicantModel>? list =
        ref.watch(applicantsControllerProvider(widget.jobId)).valueOrNull;
    if (list == null) {
      return null;
    }
    for (final ApplicantModel a in list) {
      if (a.userId == widget.userId) {
        return a;
      }
    }
    return null;
  }

  Future<void> _updateStatus(ApplicantModel applicant) async {
    final L10n l10n = L10n.of(context);
    final ApplicationStatus? chosen =
        await StatusUpdateSheet.show(context, applicant.status);
    if (chosen == null || chosen == applicant.status || !mounted) {
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(applicantStatusControllerProvider.notifier).setStatus(
            applicationId: applicant.applicationId,
            jobId: widget.jobId,
            status: chosen,
          );
      if (mounted) {
        AppSnackBar.success(context, l10n.statusUpdatedSuccess);
        context.pop();
      }
    } catch (error) {
      if (mounted) {
        AppSnackBar.error(
          context,
          localizedApiError(l10n, error,
              overrides: <int, String>{403: l10n.errorForbidden}),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final ApplicantModel? applicant = _resolve();

    if (applicant == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.applicantDetailTitle)),
        body: EmptyState(
          icon: Icons.person_off_outlined,
          title: l10n.errorNotFound,
          actionLabel: l10n.actionRetry,
          onAction: () => ref
              .read(applicantsControllerProvider(widget.jobId).notifier)
              .refresh(),
        ),
      );
    }

    final Color statusColor = applicant.status.color;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.applicantDetailTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          // Header
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary,
                child: Text(
                  applicant.initials,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(applicant.fullName, style: AppTextStyles.titleLarge),
                    if ((applicant.email ?? '').isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(applicant.email!, style: AppTextStyles.bodyMedium),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Status + timeline
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(applicant.status.icon, color: statusColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      applicant.status.localizedLabel(l10n),
                      style: AppTextStyles.titleMedium
                          .copyWith(color: statusColor),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                StatusTimeline(status: applicant.status),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: <Widget>[
                _InfoRow(
                  icon: Icons.menu_book_outlined,
                  label: l10n.fieldDepartment,
                  value: applicant.department,
                ),
                _InfoRow(
                  icon: Icons.account_balance_outlined,
                  label: l10n.fieldFaculty,
                  value: applicant.faculty,
                ),
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: l10n.labelClassYear,
                  value: applicant.classYear?.toString(),
                ),
                _InfoRow(
                  icon: Icons.grade_outlined,
                  label: l10n.labelGpa,
                  value: applicant.gpa?.toStringAsFixed(2),
                ),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: l10n.labelPhone,
                  value: applicant.phone,
                ),
                _InfoRow(
                  icon: Icons.event_available_outlined,
                  label: l10n.labelExpectedGraduation,
                  value: applicant.expectedGraduationDate == null
                      ? null
                      : MaterialLocalizations.of(context)
                          .formatMediumDate(applicant.expectedGraduationDate!),
                ),
                _InfoRow(
                  icon: Icons.schedule,
                  label: l10n.labelAppliedDate,
                  value: applicant.appliedAt == null
                      ? null
                      : MaterialLocalizations.of(context)
                          .formatMediumDate(applicant.appliedAt!),
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: l10n.updateStatusAction,
            icon: Icons.published_with_changes,
            isLoading: _busy,
            onPressed: () => _updateStatus(applicant),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String? value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final String shown =
        (value ?? '').trim().isEmpty ? l10n.notProvided : value!.trim();
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Fixed-width label column so every value starts at the same x.
              SizedBox(
                width: 160,
                child: Row(
                  children: <Widget>[
                    Icon(icon, size: 18, color: AppColors.primaryLight),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(label, style: AppTextStyles.bodyMedium),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    shown,
                    textAlign: TextAlign.left,
                    style: AppTextStyles.label,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }
}
