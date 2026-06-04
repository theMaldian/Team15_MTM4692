import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/features/auth/presentation/controllers/forgot_password_controller.dart';
import 'package:ytu_assistant/features/auth/presentation/screens/_auth_error.dart';
import 'package:ytu_assistant/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:ytu_assistant/features/auth/presentation/widgets/email_field.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';
import 'package:ytu_assistant/shared/widgets/app_snack_bar.dart';
import 'package:ytu_assistant/shared/widgets/primary_button.dart';
import 'package:ytu_assistant/shared/widgets/secondary_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final L10n l10n = L10n.of(context);
    try {
      await ref
          .read(forgotPasswordControllerProvider.notifier)
          .forgot(_email.text);
      if (!mounted) {
        return;
      }
      setState(() => _sent = true);
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
    final bool isLoading =
        ref.watch(forgotPasswordControllerProvider).isLoading;

    if (_sent) {
      final String email = _email.text.trim().toLowerCase();
      return AuthScaffold(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => context.go('/login'),
        ),
        title: l10n.checkEmailTitle,
        subtitle: l10n.checkEmailSubtitle(email),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            PrimaryButton(
              label: l10n.actionEnterResetCode,
              onPressed: () => context.go(
                '/reset-password?email=${Uri.encodeQueryComponent(email)}',
              ),
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              label: l10n.actionBackToSignIn,
              onPressed: () => context.go('/login'),
            ),
          ],
        ),
      );
    }

    return AuthScaffold(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: AppColors.textPrimary,
        onPressed: isLoading ? null : () => context.go('/login'),
      ),
      title: l10n.forgotTitle,
      subtitle: l10n.forgotSubtitle,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            EmailField(
              controller: _email,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: l10n.actionSendCode,
              isLoading: isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
