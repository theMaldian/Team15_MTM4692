import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/validators/auth_validators.dart';
import 'package:ytu_assistant/features/auth/presentation/controllers/forgot_password_controller.dart';
import 'package:ytu_assistant/features/auth/presentation/screens/_auth_error.dart';
import 'package:ytu_assistant/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:ytu_assistant/features/auth/presentation/widgets/password_field.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';
import 'package:ytu_assistant/shared/widgets/app_snack_bar.dart';
import 'package:ytu_assistant/shared/widgets/primary_button.dart';

/// Logged-in users only. Wired into the router under /change-password
/// (auth-only). The profile feature will link to this from settings.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _current = TextEditingController();
  final TextEditingController _next = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    try {
      await ref.read(forgotPasswordControllerProvider.notifier).change(
            currentPassword: _current.text,
            newPassword: _next.text,
          );
      if (!mounted) {
        return;
      }
      AppSnackBar.success(context, 'Password changed.');
      context.pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      AppSnackBar.error(
        context,
        authErrorMessage(error, on401: 'Current password is incorrect'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading =
        ref.watch(forgotPasswordControllerProvider).isLoading;
    final AuthValidators v = AuthValidators(L10n.of(context));

    return AuthScaffold(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: AppColors.textPrimary,
        onPressed: isLoading ? null : () => context.pop(),
      ),
      title: 'Change password',
      subtitle: 'Enter your current password and pick a new one.',
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            PasswordField(
              controller: _current,
              label: 'Current password',
              validator: v.loginPassword,
              autofillHints: const <String>[AutofillHints.password],
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _next,
              label: 'New password',
              validator: v.signupPassword,
              showStrengthHints: true,
              autofillHints: const <String>[AutofillHints.newPassword],
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _confirm,
              label: 'Confirm new password',
              textInputAction: TextInputAction.done,
              validator: v.matches(_next, 'Passwords do not match'),
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Change password',
              isLoading: isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
