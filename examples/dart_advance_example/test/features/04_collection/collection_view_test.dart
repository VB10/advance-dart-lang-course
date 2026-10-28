import 'package:dart_advance_example/features/04_collection/view/collection_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('every page renders both screens', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CollectionView()));

    final pages = CollectionExamples().build();
    for (final (index, page) in pages.indexed) {
      expect(find.text(page.title), findsOneWidget);
      expect(find.text('${index + 1} / ${pages.length}'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('address page: crash vs add-address empty state', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CollectionView()));

    expect(find.text('Ödeme ekranı açılamadı'), findsOneWidget);
    expect(find.text('Adres ekle'), findsOneWidget);
  });
}
