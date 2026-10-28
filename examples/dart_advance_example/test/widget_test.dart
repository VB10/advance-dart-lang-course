import 'package:dart_advance_example/features/home/model/home_topic.dart';
import 'package:dart_advance_example/features/home/view/home_keys.dart';
import 'package:dart_advance_example/features/home/view/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home shows empty state without topics', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeView(topics: [])));

    expect(find.byKey(HomeKeys.empty), findsOneWidget);
    expect(find.byKey(HomeKeys.list), findsNothing);
  });

  testWidgets('home shows a button and opens its page', (tester) async {
    final topic = HomeTopic(
      number: 1,
      title: 'Sample',
      builder: (_) => const Scaffold(body: Text('Sample page')),
    );
    await tester.pumpWidget(MaterialApp(home: HomeView(topics: [topic])));

    await tester.tap(find.byKey(HomeKeys.topic(topic.number)));
    await tester.pumpAndSettle();

    expect(find.text('Sample page'), findsOneWidget);
  });
}
