import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ytu_assistant/core/constants/ytu_faculties.dart';
import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/core/validators/auth_validators.dart';
import 'package:ytu_assistant/features/auth/data/models/auth_requests.dart';
import 'package:ytu_assistant/features/auth/presentation/controllers/register_controller.dart';
import 'package:ytu_assistant/features/auth/presentation/screens/_auth_error.dart';
import 'package:ytu_assistant/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:ytu_assistant/features/auth/presentation/widgets/email_field.dart';
import 'package:ytu_assistant/features/auth/presentation/widgets/password_field.dart';
import 'package:ytu_assistant/features/auth/presentation/widgets/role_badge.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';
import 'package:ytu_assistant/shared/widgets/app_snack_bar.dart';
import 'package:ytu_assistant/shared/widgets/app_text_field.dart';
import 'package:ytu_assistant/shared/widgets/primary_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordConfirm = TextEditingController();

  // Faculty + department are collected here but, per the backend contract,
  // are NOT sent with /auth/register — they are saved to the profile after the
  // user signs in (see RegisterRequest). Stored as plain strings.
  String? _faculty;
  String? _department;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final L10n l10n = L10n.of(context);
    final RegisterRequest request = RegisterRequest(
      email: _email.text.trim().toLowerCase(),
      password: _password.text,
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
    );

    try {
      await ref.read(registerControllerProvider.notifier).submit(request);
      if (!mounted) {
        return;
      }
      AppSnackBar.success(context, l10n.snackAccountCreated);
      context.go(
        '/verify-email?email=${Uri.encodeQueryComponent(request.email)}',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      AppSnackBar.error(
        context,
        authErrorMessage(error, l10n: l10n, on409: l10n.snackEmailExists),
      );
    }
  }

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
      prefixIcon: Icon(
        icon,
        size: 20,
        color: enabled ? AppColors.primaryLight : AppColors.textSecondary,
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: enabled ? 0.6 : 0.35),
      border: border(AppColors.border, 1),
      enabledBorder: border(AppColors.border, 1),
      disabledBorder: border(AppColors.border, 1),
      focusedBorder: border(AppColors.primary, 2),
      errorBorder: border(AppColors.error, 1),
      focusedErrorBorder: border(AppColors.error, 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final AuthValidators v = AuthValidators(l10n);
    final bool isLoading = ref.watch(registerControllerProvider).isLoading;
    final List<String> departments = departmentsForFaculty(_faculty);
    final bool facultyChosen = _faculty != null;

    return AuthScaffold(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: AppColors.textPrimary,
        onPressed: isLoading ? null : () => context.pop(),
      ),
      title: l10n.registerTitle,
      subtitle: l10n.registerSubtitle,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: AppTextField(
                      label: l10n.fieldFirstName,
                      controller: _firstName,
                      validator: v.name,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const <String>[AutofillHints.givenName],
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: l10n.fieldLastName,
                      controller: _lastName,
                      validator: v.name,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const <String>[AutofillHints.familyName],
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              EmailField(
                controller: _email,
                label: l10n.fieldEmail,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _email.text.isEmpty
                    ? const SizedBox.shrink()
                    : Align(
                        key: ValueKey<String>(_email.text),
                        alignment: Alignment.centerLeft,
                        child: RoleBadge(email: _email.text),
                      ),
              ),
              const SizedBox(height: 16),
              // ---- Faculty dropdown (Turkish catalog) ----
              DropdownButtonFormField<String>(
                initialValue: _faculty,
                isExpanded: true,
                decoration: _dropdownDecoration(
                  label: l10n.fieldFaculty,
                  icon: Icons.account_balance_outlined,
                  enabled: true,
                ),
                items: kYtuFacultyNames
                    .map(
                      (String f) => DropdownMenuItem<String>(
                        value: f,
                        child: Text(f, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: isLoading
                    ? null
                    : (String? value) => setState(() {
                          _faculty = value;
                          _department = null; // reset on faculty change
                        }),
                validator: (String? value) =>
                    value == null ? l10n.chooseFaculty : null,
              ),
              const SizedBox(height: 16),
              // ---- Department dropdown (depends on faculty) ----
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
                    .map(
                      (String d) => DropdownMenuItem<String>(
                        value: d,
                        child: Text(d, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (!facultyChosen || isLoading)
                    ? null
                    : (String? value) => setState(() => _department = value),
                validator: (String? value) =>
                    value == null ? l10n.chooseDepartment : null,
              ),
              const SizedBox(height: 16),
              PasswordField(
                controller: _password,
                label: l10n.fieldPassword,
                validator: v.signupPassword,
                showStrengthHints: true,
                autofillHints: const <String>[AutofillHints.newPassword],
              ),
              const SizedBox(height: 16),
              PasswordField(
                controller: _passwordConfirm,
                label: l10n.fieldPasswordConfirm,
                textInputAction: TextInputAction.done,
                validator: v.matches(_password),
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 4),
              Text(l10n.registerNote, style: AppTextStyles.caption),
              const SizedBox(height: 20),
              PrimaryButton(
                label: l10n.actionRegister,
                isLoading: isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    l10n.haveAccountQuestion,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: isLoading ? null : () => context.go('/login'),
                    child: Text(l10n.actionSignIn),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
