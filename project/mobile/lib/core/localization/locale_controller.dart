import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/core/storage/secure_storage.dart';

/// Language codes the app ships with. Turkish is the default.
const List<String> kSupportedLanguageCodes = <String>['tr', 'en'];

/// Holds the active [Locale]. Defaults to Turkish, restores the persisted
/// choice from secure storage on startup, and persists every change.
class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    // Kick off a best-effort restore; until it resolves we render Turkish.
    _restore();
    return const Locale('tr');
  }

  Future<void> _restore() async {
    final String? code = await ref.read(secureStorageProvider).readLocale();
    if (code != null &&
        kSupportedLanguageCodes.contains(code) &&
        code != state.languageCode) {
      state = Locale(code);
    }
  }

  /// Switches to [locale] (if supported) and persists the choice.
  Future<void> setLocale(Locale locale) async {
    if (!kSupportedLanguageCodes.contains(locale.languageCode)) {
      return;
    }
    state = locale;
    await ref.read(secureStorageProvider).saveLocale(locale.languageCode);
  }

  /// Flips between Turkish and English.
  Future<void> toggle() {
    final Locale next =
        state.languageCode == 'tr' ? const Locale('en') : const Locale('tr');
    return setLocale(next);
  }
}

final localeProvider =
    NotifierProvider<LocaleController, Locale>(LocaleController.new);
