import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/validators/auth_validators.dart';
import 'package:ytu_assistant/features/auth/presentation/controllers/forgot_password_controller.dart';
import 'package:ytu_assistant/features/auth/presentation/screens/_auth_error.dart';
import 'package:ytu_assistant/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:ytu_assistant/features/auth/presentation/widgets/email_field.dart';
import 'package:ytu_assistant/features/auth/presentation/widgets/password_field.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';
import 'package:ytu_assistant/shared/widgets/app_snack_bar.dart';
import 'package:ytu_assistant/shared/widgets/app_text_field.dart';
import 'package:ytu_assistant/shared/widgets/primary_button.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, this.email});

  /// Optional pre-filled email coming from /forgot-password.
  final String? email;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _email;
  final TextEditingController _code = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordConfirm = TextEditingController();

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: widget.email ?? '');
  }

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
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
    try {
      await ref.read(forgotPasswordControllerProvider.notifier).reset(
            email: _email.text,
            code: _code.text,
            newPassword: _password.text,
          );
      if (!mounted) {
        return;
      }
      AppSnackBar.success(context, l10n.snackPasswordReset);
      context.go('/login');
    } catch (error) {
      if (!mounted) {
        return;
      }
      AppSnackBar.error(context, authErrorMessage(error, l10n: l10n));
    }
  }

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final AuthValidators v = AuthValidators(l10n);
    final bool isLoading =
        ref.watch(forgotPasswordControllerProvider).isLoading;

    return AuthScaffold(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: AppColors.textPrimary,
        onPressed: isLoading ? null : () => context.go('/login'),
      ),
      title: l10n.resetTitle,
      subtitle: l10n.resetSubtitle,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            EmailField(controller: _email),
            const SizedBox(height: 16),
            AppTextField(
              label: l10n.fieldResetCode,
              hint: l10n.hintSixDigitCode,
              controller: _code,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: v.sixDigitCode,
              prefixIcon: Icons.pin_outlined,
              autofillHints: const <String>[AutofillHints.oneTimeCode],
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _password,
              label: l10n.fieldNewPassword,
              validator: v.signupPassword,
              showStrengthHints: true,
              autofillHints: const <String>[AutofillHints.newPassword],
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _passwordConfirm,
              label: l10n.fieldConfirmNewPassword,
              textInputAction: TextInputAction.done,
              validator: v.matches(_password),
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: l10n.actionReset,
              isLoading: isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
