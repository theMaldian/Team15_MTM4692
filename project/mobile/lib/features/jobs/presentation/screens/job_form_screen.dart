import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ytu_assistant/core/network/localized_error.dart';
import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/core/utils/date_formatter.dart';
import 'package:ytu_assistant/features/auth/data/models/user_model.dart';
import 'package:ytu_assistant/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ytu_assistant/features/jobs/data/models/job_model.dart';
import 'package:ytu_assistant/features/jobs/data/models/job_requests.dart';
import 'package:ytu_assistant/features/jobs/domain/job_category.dart';
import 'package:ytu_assistant/features/jobs/presentation/controllers/job_detail_controller.dart';
import 'package:ytu_assistant/features/jobs/presentation/controllers/job_form_controller.dart';
import 'package:ytu_assistant/features/jobs/presentation/job_category_l10n.dart';
import 'package:ytu_assistant/features/jobs/presentation/widgets/empty_state.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';
import 'package:ytu_assistant/shared/widgets/app_snack_bar.dart';
import 'package:ytu_assistant/shared/widgets/app_text_field.dart';
import 'package:ytu_assistant/shared/widgets/primary_button.dart';
import 'package:ytu_assistant/shared/widgets/skeleton_box.dart';

/// Create (`/jobs/new`) or edit (`/jobs/:id/edit`) a posting.
class JobFormScreen extends ConsumerStatefulWidget {
  const JobFormScreen({super.key, this.jobId});

  /// Null = create mode; non-null = edit mode.
  final int? jobId;

  bool get isEdit => jobId != null;

  @override
  ConsumerState<JobFormScreen> createState() => _JobFormScreenState();
}

class _JobFormScreenState extends ConsumerState<JobFormScreen> {
  static const int _descriptionMax = 2000;
  static const int _positionMax = 100;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _position = TextEditingController();
  final TextEditingController _department = TextEditingController();
  final TextEditingController _description = TextEditingController();

  JobCategory? _category;
  DateTime? _deadline;
  String? _deadlineError;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isEdit) {
      final UserModel? user = ref.read(authControllerProvider).valueOrNull;
      final String? dept = user?.department;
      if (dept != null && dept.isNotEmpty) {
        _department.text = dept;
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _position.dispose();
    _department.dispose();
    _description.dispose();
    super.dispose();
  }

  void _prefillOnce(JobModel job) {
    if (_initialized) {
      return;
    }
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _position.text = job.position;
        _department.text = job.departmentName;
        _description.text = job.description;
        _category = job.category;
        _deadline = job.deadline;
      });
    });
  }

  Future<void> _pickDeadline() async {
    final DateTime now = DateTime.now();
    final DateTime first = DateTime(now.year, now.month, now.day)
        .add(const Duration(days: 1));
    final DateTime initial =
        (_deadline != null && _deadline!.isAfter(first)) ? _deadline! : first;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime(now.year + 2, now.month, now.day),
    );
    if (picked != null) {
      setState(() {
        _deadline = picked;
        _deadlineError = null;
      });
    }
  }

  Future<void> _submit() async {
    final L10n l10n = L10n.of(context);
    FocusScope.of(context).unfocus();
    final bool formValid = _formKey.currentState!.validate();
    final bool deadlineValid = _deadline != null;
    if (!deadlineValid) {
      setState(() => _deadlineError = l10n.deadlineRequired);
    }
    if (!formValid || !deadlineValid) {
      return;
    }

    try {
      if (widget.isEdit) {
        await ref.read(jobFormControllerProvider.notifier).submitUpdate(
              widget.jobId!,
              UpdateJobRequest(
                jobCategory: _category,
                departmentName: _department.text.trim(),
                position: _position.text.trim(),
                description: _description.text.trim(),
                deadline: _deadline,
              ),
            );
      } else {
        await ref.read(jobFormControllerProvider.notifier).submitCreate(
              CreateJobRequest(
                jobCategory: _category!,
                departmentName: _department.text.trim(),
                position: _position.text.trim(),
                description: _description.text.trim(),
                deadline: _deadline!,
              ),
            );
      }
      if (!mounted) {
        return;
      }
      AppSnackBar.success(
        context,
        widget.isEdit ? l10n.changesSavedMsg : l10n.postingPublishedMsg,
      );
      context.pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      final L10n l = L10n.of(context);
      AppSnackBar.error(
        context,
        localizedApiError(l, error, overrides: <int, String>{
          403: l.errorForbidden,
          404: l.postingNotFound,
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final String title =
        widget.isEdit ? l10n.jobFormEditTitle : l10n.jobFormNewTitle;

    if (widget.isEdit) {
      final AsyncValue<JobModel> jobAsync =
          ref.watch(jobDetailControllerProvider(widget.jobId!));
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: jobAsync.when(
          loading: () => const _FormSkeleton(),
          error: (Object error, _) => EmptyState(
            icon: Icons.error_outline,
            title: l10n.couldNotLoadPosting,
            subtitle: localizedApiError(l10n, error),
            actionLabel: l10n.actionGoBack,
            onAction: () => context.pop(),
          ),
          data: (JobModel job) {
            _prefillOnce(job);
            return _form(l10n);
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _form(l10n),
    );
  }

  Widget _form(L10n l10n) {
    final bool isLoading = ref.watch(jobFormControllerProvider).isLoading;

    return Column(
      children: <Widget>[
        Expanded(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: <Widget>[
                AppTextField(
                  label: l10n.fieldPosition,
                  hint: l10n.positionHint,
                  controller: _position,
                  maxLength: _positionMax,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.badge_outlined,
                  validator: (String? v) {
                    final String s = (v ?? '').trim();
                    if (s.isEmpty) {
                      return l10n.jobPositionRequired;
                    }
                    if (s.length > _positionMax) {
                      return l10n.jobPositionTooLong(_positionMax);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<JobCategory>(
                  initialValue: _category,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.filterCategory,
                    prefixIcon: const Icon(Icons.category_outlined, size: 20),
                  ),
                  items: JobCategory.values
                      .map(
                        (JobCategory c) => DropdownMenuItem<JobCategory>(
                          value: c,
                          child: Text(c.localizedLabel(l10n)),
                        ),
                      )
                      .toList(),
                  onChanged: isLoading
                      ? null
                      : (JobCategory? value) =>
                          setState(() => _category = value),
                  validator: (JobCategory? value) =>
                      value == null ? l10n.chooseCategoryPrompt : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: l10n.fieldDepartment,
                  hint: l10n.deptHint,
                  controller: _department,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.account_balance_outlined,
                  validator: (String? v) =>
                      (v ?? '').trim().isEmpty ? l10n.deptRequired : null,
                ),
                const SizedBox(height: 16),
                _DescriptionField(
                  controller: _description,
                  maxLength: _descriptionMax,
                ),
                const SizedBox(height: 16),
                _DeadlinePicker(
                  deadline: _deadline,
                  errorText: _deadlineError,
                  onTap: isLoading ? null : _pickDeadline,
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: PrimaryButton(
            label: widget.isEdit ? l10n.saveChangesAction : l10n.publishAction,
            isLoading: isLoading,
            onPressed: _submit,
          ),
        ),
      ],
    );
  }
}

class _DescriptionField extends StatelessWidget {
  const _DescriptionField({required this.controller, required this.maxLength});

  final TextEditingController controller;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    return TextFormField(
      controller: controller,
      maxLines: 6,
      minLines: 4,
      maxLength: maxLength,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: l10n.fieldDescription,
        hintText: l10n.descriptionHint,
        alignLabelWithHint: true,
      ),
      validator: (String? v) {
        final String s = (v ?? '').trim();
        if (s.isEmpty) {
          return l10n.descriptionRequired;
        }
        if (s.length > maxLength) {
          return l10n.descriptionTooLong(maxLength);
        }
        return null;
      },
    );
  }
}

class _DeadlinePicker extends StatelessWidget {
  const _DeadlinePicker({
    required this.deadline,
    required this.errorText,
    required this.onTap,
  });

  final DateTime? deadline;
  final String? errorText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.applicationDeadlineLabel,
          errorText: errorText,
          prefixIcon: const Icon(Icons.event_outlined, size: 20),
        ),
        child: Text(
          deadline == null
              ? l10n.selectDate
              : DateFormatter.fullDate(deadline!),
          style: AppTextStyles.bodyLarge.copyWith(
            color: deadline == null
                ? AppColors.textSecondary
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _FormSkeleton extends StatelessWidget {
  const _FormSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const <Widget>[
        SkeletonBox(height: 56, borderRadius: 12),
        SizedBox(height: 16),
        SkeletonBox(height: 56, borderRadius: 12),
        SizedBox(height: 16),
        SkeletonBox(height: 56, borderRadius: 12),
        SizedBox(height: 16),
        SkeletonBox(height: 140, borderRadius: 12),
        SizedBox(height: 16),
        SkeletonBox(height: 56, borderRadius: 12),
      ],
    );
  }
}
