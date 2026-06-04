import 'package:flutter/material.dart';

import 'package:ytu_assistant/core/validators/auth_validators.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';
import 'package:ytu_assistant/shared/widgets/app_text_field.dart';

/// Pre-configured email field used by every auth form. Label/hint default to
/// the localized strings unless overridden.
class EmailField extends StatelessWidget {
  const EmailField({
    super.key,
    required this.controller,
    this.onChanged,
    this.textInputAction = TextInputAction.next,
    this.label,
    this.hint,
    this.enabled = true,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final TextInputAction textInputAction;
  final String? label;
  final String? hint;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    return AppTextField(
      label: label ?? l10n.fieldEmail,
      hint: hint ?? l10n.emailHint,
      controller: controller,
      validator: AuthValidators(l10n).email,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      autocorrect: false,
      enableSuggestions: false,
      autofillHints: const <String>[AutofillHints.email],
      onChanged: onChanged,
      prefixIcon: Icons.alternate_email,
      enabled: enabled,
      textCapitalization: TextCapitalization.none,
    );
  }
}
