import 'package:dart_advance_example/features/home/view/topic_examples_view.dart';
import 'package:dart_advance_example/features/02_typedefs/model/typedefs_examples.dart';
import 'package:flutter/material.dart';

final class TypedefsView extends StatelessWidget {
  const TypedefsView({super.key});

  @override
  Widget build(BuildContext context) {
    return TopicExamplesView(
      title: '02  Typedefs',
      examples: TypedefsExamples().build(),
    );
  }
}
