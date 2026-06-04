import 'package:flutter/widgets.dart';

import 'package:ytu_assistant/core/constants/app_constants.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';

/// Localized validators for auth forms. Construct with the active [L10n]
/// (`AuthValidators(L10n.of(context))`); each method returns `null` when valid
/// or a localized error message for the field-error UI.
class AuthValidators {
  AuthValidators(this._l10n);

  final L10n _l10n;

  static final RegExp _emailFormat = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  static final RegExp _hasLetter = RegExp(r'[A-Za-z]');
  static final RegExp _hasNumber = RegExp(r'[0-9]');
  static final RegExp _digitsOnly = RegExp(r'^\d+$');

  /// Required, valid format, and ends with a YTU domain.
  String? email(String? value) {
    final String input = (value ?? '').trim().toLowerCase();
    if (input.isEmpty) {
      return _l10n.valEmailRequired;
    }
    if (!_emailFormat.hasMatch(input)) {
      return _l10n.valEmailInvalid;
    }
    if (!input.endsWith(AppConstants.studentEmailDomain) &&
        !input.endsWith(AppConstants.professorEmailDomain)) {
      return _l10n.valEmailDomain(
        AppConstants.studentEmailDomain,
        AppConstants.professorEmailDomain,
      );
    }
    return null;
  }

  /// Sign-up: min 8 chars, at least one letter and one number.
  String? signupPassword(String? value) {
    final String input = value ?? '';
    if (input.isEmpty) {
      return _l10n.valPasswordRequired;
    }
    if (input.length < 8) {
      return _l10n.valPasswordMin;
    }
    if (!_hasLetter.hasMatch(input)) {
      return _l10n.valPasswordLetter;
    }
    if (!_hasNumber.hasMatch(input)) {
      return _l10n.valPasswordNumber;
    }
    return null;
  }

  /// Login: just non-empty.
  String? loginPassword(String? value) {
    if ((value ?? '').isEmpty) {
      return _l10n.valPasswordRequired;
    }
    return null;
  }

  /// Required name, 2–50 chars.
  String? name(String? value) {
    final String input = (value ?? '').trim();
    if (input.isEmpty) {
      return _l10n.valRequired;
    }
    if (input.length < 2) {
      return _l10n.valMinChars;
    }
    if (input.length > 50) {
      return _l10n.valMaxChars;
    }
    return null;
  }

  /// Confirm password must match the controller's text exactly.
  String? Function(String?) matches(
    TextEditingController other, [
    String? message,
  ]) {
    return (String? value) {
      if (value != other.text) {
        return message ?? _l10n.passwordsDoNotMatch;
      }
      return null;
    };
  }

  /// Generic required-string validator.
  String? required(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return _l10n.valRequired;
    }
    return null;
  }

  /// 6-digit verification / reset code.
  String? sixDigitCode(String? value) {
    final String input = (value ?? '').trim();
    if (input.isEmpty) {
      return _l10n.valCodeRequired;
    }
    if (input.length != 6 || !_digitsOnly.hasMatch(input)) {
      return _l10n.valCodeSixDigits;
    }
    return null;
  }
}
