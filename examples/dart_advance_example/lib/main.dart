import 'package:dart_advance_example/features/home/model/home_topic.dart';
import 'package:dart_advance_example/features/home/view/home_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

final class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dart Advance',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomeView(topics: homeTopics),
    );
  }
}
