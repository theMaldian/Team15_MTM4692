import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/core/validators/auth_validators.dart';
import 'package:ytu_assistant/features/auth/presentation/controllers/verify_email_controller.dart';
import 'package:ytu_assistant/features/auth/presentation/screens/_auth_error.dart';
import 'package:ytu_assistant/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';
import 'package:ytu_assistant/shared/widgets/app_snack_bar.dart';
import 'package:ytu_assistant/shared/widgets/app_text_field.dart';
import 'package:ytu_assistant/shared/widgets/primary_button.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  static const int _resendCooldownSeconds = 60;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _code = TextEditingController();
  int _cooldown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _code.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _cooldown = _resendCooldownSeconds);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _cooldown--);
      if (_cooldown <= 0) {
        t.cancel();
      }
    });
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final L10n l10n = L10n.of(context);
    try {
      await ref.read(verifyEmailControllerProvider.notifier).verify(
            email: widget.email,
            code: _code.text.trim(),
          );
      if (!mounted) {
        return;
      }
      AppSnackBar.success(context, l10n.snackEmailVerified);
      context.go('/login');
    } catch (error) {
      if (!mounted) {
        return;
      }
      AppSnackBar.error(context, authErrorMessage(error, l10n: l10n));
    }
  }

  Future<void> _resend() async {
    if (_cooldown > 0) {
      return;
    }
    final L10n l10n = L10n.of(context);
    try {
      await ref
          .read(verifyEmailControllerProvider.notifier)
          .resend(widget.email);
      if (!mounted) {
        return;
      }
      AppSnackBar.success(context, l10n.snackCodeSent);
      _startCooldown();
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
    final bool isLoading = ref.watch(verifyEmailControllerProvider).isLoading;

    return AuthScaffold(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: AppColors.textPrimary,
        onPressed: isLoading ? null : () => context.go('/login'),
      ),
      title: l10n.verifyTitle,
      subtitle: l10n.verifySubtitle(widget.email),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppTextField(
              label: l10n.fieldVerificationCode,
              hint: l10n.hintSixDigitCode,
              controller: _code,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: AuthValidators(l10n).sixDigitCode,
              prefixIcon: Icons.pin_outlined,
              autofillHints: const <String>[AutofillHints.oneTimeCode],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _verify(),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: l10n.actionVerify,
              isLoading: isLoading,
              onPressed: _verify,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  l10n.noCodeQuestion,
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
                  onPressed: (isLoading || _cooldown > 0) ? null : _resend,
                  child: Text(
                    _cooldown > 0 ? l10n.resendIn(_cooldown) : l10n.actionResend,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.codeExpiresNote,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}
