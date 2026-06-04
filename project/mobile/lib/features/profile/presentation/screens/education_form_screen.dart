import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ytu_assistant/core/network/localized_error.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/features/profile/data/models/education_model.dart';
import 'package:ytu_assistant/features/profile/presentation/controllers/educations_controller.dart';
import 'package:ytu_assistant/features/profile/presentation/widgets/date_picker_field.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';
import 'package:ytu_assistant/shared/widgets/app_snack_bar.dart';
import 'package:ytu_assistant/shared/widgets/app_text_field.dart';
import 'package:ytu_assistant/shared/widgets/primary_button.dart';

/// Add or edit a single education entry. Pass an [EducationModel] via go_router
/// `extra` to edit; omit it to create.
class EducationFormScreen extends ConsumerStatefulWidget {
  const EducationFormScreen({super.key, this.education});

  final EducationModel? education;

  @override
  ConsumerState<EducationFormScreen> createState() =>
      _EducationFormScreenState();
}

class _EducationFormScreenState extends ConsumerState<EducationFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _university = TextEditingController();
  final TextEditingController _department = TextEditingController();
  final TextEditingController _gpa = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _ongoing = false;

  bool get _isEdit => widget.education != null;

  @override
  void initState() {
    super.initState();
    final EducationModel? e = widget.education;
    if (e != null) {
      _university.text = e.university ?? '';
      _department.text = e.department ?? '';
      _gpa.text = e.gpa?.toString() ?? '';
      _startDate = e.startDate;
      _endDate = e.endDate;
      _ongoing = e.isOngoing;
    }
  }

  @override
  void dispose() {
    _university.dispose();
    _department.dispose();
    _gpa.dispose();
    super.dispose();
  }

  String? _trimOrNull(String v) {
    final String t = v.trim();
    return t.isEmpty ? null : t;
  }

  String? _validateGpa(String? v, L10n l10n) {
    final String t = (v ?? '').trim();
    if (t.isEmpty) {
      return null;
    }
    final double? g = double.tryParse(t);
    if (g == null || g < 0 || g > 4) {
      return l10n.valGpaRange;
    }
    return null;
  }

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    final L10n l10n = L10n.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Backend requires at least one of university/department.
    if (_trimOrNull(_university.text) == null &&
        _trimOrNull(_department.text) == null) {
      AppSnackBar.error(context, l10n.valRequired);
      return;
    }
    final Map<String, dynamic> body = <String, dynamic>{
      'university': _trimOrNull(_university.text),
      'department': _trimOrNull(_department.text),
      'gpa': double.tryParse(_gpa.text.trim()),
      'start_date': _startDate == null ? null : _isoDate(_startDate!),
      'end_date': _ongoing || _endDate == null ? null : _isoDate(_endDate!),
    };

    try {
      final EducationsController c =
          ref.read(educationsControllerProvider.notifier);
      if (_isEdit) {
        await c.edit(widget.education!.id, body);
      } else {
        await c.create(body);
      }
      if (mounted) {
        context.pop();
      }
    } catch (error) {
      if (mounted) {
        AppSnackBar.error(context, localizedApiError(l10n, error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final bool isLoading = ref.watch(educationsControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(_isEdit ? l10n.educationEditTitle : l10n.educationAddTitle),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            AppTextField(
              label: l10n.fieldUniversity,
              controller: _university,
              prefixIcon: Icons.school_outlined,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: l10n.fieldDepartment,
              controller: _department,
              prefixIcon: Icons.menu_book_outlined,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: l10n.fieldGpa,
              controller: _gpa,
              prefixIcon: Icons.grade_outlined,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (String? v) => _validateGpa(v, l10n),
            ),
            const SizedBox(height: 16),
            DatePickerField(
              label: l10n.fieldStartDate,
              value: _startDate,
              onChanged: (DateTime? v) => setState(() => _startDate = v),
            ),
            const SizedBox(height: 16),
            DatePickerField(
              label: l10n.fieldEndDate,
              value: _ongoing ? null : _endDate,
              enabled: !_ongoing,
              onChanged: (DateTime? v) => setState(() => _endDate = v),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.ongoing, style: AppTextStyles.bodyLarge),
              value: _ongoing,
              onChanged: (bool v) => setState(() {
                _ongoing = v;
                if (v) {
                  _endDate = null;
                }
              }),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: l10n.actionSave,
              isLoading: isLoading,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
