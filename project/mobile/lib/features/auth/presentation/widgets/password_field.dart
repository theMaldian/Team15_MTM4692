import 'package:flutter/material.dart';

import 'package:ytu_assistant/core/theme/app_colors.dart';
import 'package:ytu_assistant/core/theme/app_text_styles.dart';
import 'package:ytu_assistant/core/validators/auth_validators.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';
import 'package:ytu_assistant/shared/widgets/app_text_field.dart';

/// Password field with a show/hide toggle. When [showStrengthHints] is true a
/// small rule-list shows below the field to guide sign-up users.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.showStrengthHints = false,
    this.autofillHints = const <String>[AutofillHints.password],
    this.onFieldSubmitted,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final bool showStrengthHints;
  final Iterable<String> autofillHints;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;
  String _value = '';

  @override
  void initState() {
    super.initState();
    _value = widget.controller.text;
    widget.controller.addListener(_handleChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    if (!mounted) {
      return;
    }
    if (_value != widget.controller.text) {
      setState(() => _value = widget.controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context);
    final String? Function(String?) validator =
        widget.validator ?? AuthValidators(l10n).loginPassword;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppTextField(
          label: widget.label ?? l10n.fieldPassword,
          hint: widget.hint,
          controller: widget.controller,
          validator: validator,
          obscureText: _obscure,
          prefixIcon: Icons.lock_outline,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          onFieldSubmitted: widget.onFieldSubmitted,
          onChanged: widget.onChanged,
          autocorrect: false,
          enableSuggestions: false,
          suffix: IconButton(
            icon: Icon(
              _obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.textSecondary,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
            tooltip: _obscure ? l10n.showPassword : l10n.hidePassword,
          ),
        ),
        if (widget.showStrengthHints) ...<Widget>[
          const SizedBox(height: 8),
          _StrengthHints(
            password: _value,
            lengthLabel: l10n.pwHintLength,
            letterLabel: l10n.pwHintLetter,
            numberLabel: l10n.pwHintNumber,
          ),
        ],
      ],
    );
  }
}

class _StrengthHints extends StatelessWidget {
  const _StrengthHints({
    required this.password,
    required this.lengthLabel,
    required this.letterLabel,
    required this.numberLabel,
  });

  final String password;
  final String lengthLabel;
  final String letterLabel;
  final String numberLabel;

  bool get _meetsLength => password.length >= 8;
  bool get _hasLetter => RegExp('[A-Za-z]').hasMatch(password);
  bool get _hasNumber => RegExp('[0-9]').hasMatch(password);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _hintLine(lengthLabel, _meetsLength),
        _hintLine(letterLabel, _hasLetter),
        _hintLine(numberLabel, _hasNumber),
      ],
    );
  }

  Widget _hintLine(String label, bool satisfied) {
    final Color color = satisfied ? AppColors.success : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          Icon(
            satisfied ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.caption.copyWith(color: color)),
        ],
      ),
    );
  }
}
