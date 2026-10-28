import 'package:dart_advance_example/features/03_class_design/view/class_design_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('every page renders both screens', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ClassDesignView()));

    final pages = ClassDesignExamples().build();
    for (final (index, page) in pages.indexed) {
      expect(find.text(page.title), findsOneWidget);
      expect(find.text('${index + 1} / ${pages.length}'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
    }
  });
}
