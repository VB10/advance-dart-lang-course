import 'package:dart_advance_example/features/01_builtin_types/view/builtin_types_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('every page renders both screens', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BuiltinTypesView()));

    final pages = BuiltinTypesExamples().build();
    for (final (index, page) in pages.indexed) {
      expect(find.text(page.title), findsOneWidget);
      expect(find.text('${index + 1} / ${pages.length}'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('swiping left opens the next page', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BuiltinTypesView()));
    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(
      find.text('2 / ${BuiltinTypesExamples().build().length}'),
      findsOneWidget,
    );
  });

  testWidgets('price page: raw double vs formatted cents', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BuiltinTypesView()));

    expect(find.text('24999.9 ₺'), findsOneWidget);
    expect(find.text('24.999,90 ₺'), findsOneWidget);
  });

  testWidgets('gallery page: remainder breaks, % shows the last photo', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: BuiltinTypesView()));
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    expect(find.text('Galeri açılamadı'), findsOneWidget);
    expect(find.text('5 / 5'), findsOneWidget);
  });
}
