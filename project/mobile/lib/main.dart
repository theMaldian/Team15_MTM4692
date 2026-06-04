import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ytu_assistant/app.dart';

void main() {
  // A silent exception during startup looks like a blank white screen on web.
  // Surface anything that throws while building as a visible message instead.
  ErrorWidget.builder =
      (FlutterErrorDetails details) => _StartupErrorView(details: details);

  runZonedGuarded<void>(
    () {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        debugPrint('FlutterError: ${details.exceptionAsString()}');
      };

      runApp(const ProviderScope(child: App()));
    },
    (Object error, StackTrace stack) {
      // Last-resort guard: log uncaught/async startup errors so a blank page is
      // never silent. The app itself keeps running where possible.
      debugPrint('Uncaught zone error: $error');
      debugPrint('$stack');
    },
  );
}

/// Fallback UI shown when a widget throws during build. Deliberately avoids any
/// dependency on the app theme or a [MaterialApp] ancestor so it renders even
/// when the failure happens before the app is fully wired up.
class _StartupErrorView extends StatelessWidget {
  const _StartupErrorView({required this.details});

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: const Color(0xFFFAFAFA),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
            const SizedBox(height: 16),
            const Text(
              'Bir şeyler ters gitti',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              kDebugMode
                  ? details.exceptionAsString()
                  : 'Uygulama başlatılırken bir hata oluştu.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}
