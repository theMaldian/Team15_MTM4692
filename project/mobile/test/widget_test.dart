// Smoke test: the app boots and builds its first frame without throwing.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ytu_assistant/app.dart';

void main() {
  testWidgets('App builds its first frame', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));

    expect(find.byType(App), findsOneWidget);
  });
}
