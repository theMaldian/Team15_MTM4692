import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ytu_assistant/core/constants/ytu_faculties.dart';
import 'package:ytu_assistant/core/network/localized_error.dart';
import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/features/profile/data/models/profile_model.dart';
import 'package:ytu_assistant/features/profile/presentation/controllers/profile_controller.dart';
import 'package:ytu_assistant/features/profile/presentation/controllers/profile_edit_controller.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';
import 'package:ytu_assistant/shared/widgets/app_snack_bar.dart';
import 'package:ytu_assistant/shared/widgets/app_text_field.dart';
import 'package:ytu_assistant/shared/widgets/primary_button.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _degreeLevel = TextEditingController();
  final TextEditingController _classYear = TextEditingController();
  final TextEditingController _gpa = TextEditingController();
  final TextEditingController _academicTitle = TextEditingController();

  String? _faculty;
  String? _department;
  DateTime? _expectedGraduation;
  bool _isStudent = true;

  @override
  void initState() {
    super.initState();
    final ProfileModel? p = ref.read(profileControllerProvider).valueOrNull;
    if (p != null) {
      _isStudent = p.isStudent;
      _firstName.text = p.user.firstName ?? '';
      _lastName.text = p.user.lastName ?? '';
      _phone.text = p.user.phone ?? '';
      if (kYtuFacultyNames.contains(p.user.faculty)) {
        _faculty = p.user.faculty;
        if (departmentsForFaculty(_faculty).contains(p.user.department)) {
          _department = p.user.department;
        }
      }
      final StudentProfile? sp = p.student;
      if (sp != null) {
        _degreeLevel.text = sp.degreeLevel ?? '';
        _classYear.text = sp.classYear?.toString() ?? '';
        _gpa.text = sp.gpa?.toString() ?? '';
        _expectedGraduation = sp.expectedGraduationDate;
      }
      _academicTitle.text = p.professor?.academicTitle ?? '';
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _degreeLevel.dispose();
    _classYear.dispose();
    _gpa.dispose();
    _academicTitle.dispose();
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

  String? _validateClassYear(String? v, L10n l10n) {
    final String t = (v ?? '').trim();
    if (t.isEmpty) {
      return null;
    }
    final int? y = int.tryParse(t);
    if (y == null || y < 1 || y > 8) {
      return l10n.valClassYear;
    }
    return null;
  }

  Future<void> _pickGraduation(L10n l10n) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expectedGraduation ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 12),
    );
    if (picked != null) {
      setState(() => _expectedGraduation = picked);
    }
  }

  Future<void> _save() async {
    final L10n l10n = L10n.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final Map<String, dynamic> body = <String, dynamic>{
      'first_name': _trimOrNull(_firstName.text),
      'last_name': _trimOrNull(_lastName.text),
      'phone': _trimOrNull(_phone.text),
      'faculty': _faculty,
      'department': _department,
    };
    if (_isStudent) {
      body['degree_level'] = _trimOrNull(_degreeLevel.text);
      body['class_year'] = int.tryParse(_classYear.text.trim());
      body['gpa'] = double.tryParse(_gpa.text.trim());
      body['expected_graduation_date'] = _expectedGraduation == null
          ? null
          : _isoDate(_expectedGraduation!);
    } else {
      body['academic_title'] = _trimOrNull(_academicTitle.text);
    }

    try {
      await ref.read(profileEditControllerProvider.notifier).save(body);
      if (mounted) {
        AppSnackBar.success(context, l10n.profileSavedSuccess);
        context.pop();
      }
    } catch (error) {
      if (mounted) {
        AppSnackBar.error(context, localizedApiError(l10n, error));
      }
    }
  }

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  InputDecoration _dropdownDecoration({
    required String label,
    required IconData icon,
    required bool enabled,
  }) {
    final BorderRadius radius = BorderRadius.circular(14);
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon,
          size: 20,
          color: enabled ? AppColors.primaryLight : AppColors.textSecondary),
      filled: true,
      fillColor: Colors.white.withValues(alpha: enabled ? 0.6 : 0.35),
      border: border(AppColors.border, 1),
      enabledBorder: border(AppColors.border, 1),
      disabledBorder: border(AppColors.border, 1),
      focusedBorder: border(AppColors.primary, 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final bool isLoading = ref.watch(profileEditControllerProvider).isLoading;
    final List<String> departments = departmentsForFaculty(_faculty);
    final bool facultyChosen = _faculty != null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfileTitle)),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: AppTextField(
                    label: l10n.fieldFirstName,
                    controller: _firstName,
                    prefixIcon: Icons.person_outline,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: l10n.fieldLastName,
                    controller: _lastName,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: l10n.fieldPhone,
              controller: _phone,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _faculty,
              isExpanded: true,
              decoration: _dropdownDecoration(
                label: l10n.fieldFaculty,
                icon: Icons.account_balance_outlined,
                enabled: true,
              ),
              items: kYtuFacultyNames
                  .map((String f) => DropdownMenuItem<String>(
                        value: f,
                        child: Text(f, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: isLoading
                  ? null
                  : (String? v) => setState(() {
                        _faculty = v;
                        _department = null;
                      }),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _department,
              isExpanded: true,
              decoration: _dropdownDecoration(
                label: facultyChosen
                    ? l10n.fieldDepartment
                    : l10n.selectFacultyFirst,
                icon: Icons.menu_book_outlined,
                enabled: facultyChosen,
              ),
              items: departments
                  .map((String d) => DropdownMenuItem<String>(
                        value: d,
                        child: Text(d, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (!facultyChosen || isLoading)
                  ? null
                  : (String? v) => setState(() => _department = v),
            ),
            const SizedBox(height: 16),
            if (_isStudent) ...<Widget>[
              AppTextField(
                label: l10n.fieldDegreeLevel,
                controller: _degreeLevel,
                prefixIcon: Icons.workspace_premium_outlined,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: AppTextField(
                      label: l10n.fieldClassYear,
                      controller: _classYear,
                      prefixIcon: Icons.calendar_today_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (String? v) => _validateClassYear(v, l10n),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: l10n.fieldGpa,
                      controller: _gpa,
                      prefixIcon: Icons.grade_outlined,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (String? v) => _validateGpa(v, l10n),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _DateField(
                label: l10n.fieldExpectedGraduation,
                value: _expectedGraduation,
                onTap: isLoading ? null : () => _pickGraduation(l10n),
                onClear: () => setState(() => _expectedGraduation = null),
              ),
            ] else ...<Widget>[
              AppTextField(
                label: l10n.fieldAcademicTitle,
                controller: _academicTitle,
                prefixIcon: Icons.school_outlined,
                textInputAction: TextInputAction.done,
              ),
            ],
            const SizedBox(height: 24),
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

/// A read-only field that opens a date picker on tap, with a clear button.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback? onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final String text = value == null
        ? ''
        : MaterialLocalizations.of(context).formatMediumDate(value!);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon:
              const Icon(Icons.event_outlined, size: 20, color: AppColors.primaryLight),
          suffixIcon: value == null
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: onClear,
                ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),
        child: Text(text),
      ),
    );
  }
}
