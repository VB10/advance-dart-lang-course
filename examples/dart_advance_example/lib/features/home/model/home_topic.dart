import 'package:dart_advance_example/features/01_builtin_types/view/builtin_types_view.dart';
import 'package:dart_advance_example/features/03_class_design/view/class_design_view.dart';
import 'package:dart_advance_example/features/04_collection/view/collection_view.dart';
import 'package:dart_advance_example/features/02_typedefs/view/typedefs_view.dart';
import 'package:flutter/widgets.dart';

/// One course topic shown as a button on the home screen.
///
/// Add an entry to [homeTopics] when a topic gets its example page.
final class HomeTopic {
  const HomeTopic({
    required this.number,
    required this.title,
    required this.builder,
  });

  final int number;
  final String title;
  final WidgetBuilder builder;
}

final List<HomeTopic> homeTopics = [
  HomeTopic(
    number: 1,
    title: 'Built-in types',
    builder: (_) => const BuiltinTypesView(),
  ),
  HomeTopic(number: 2, title: 'Typedefs', builder: (_) => const TypedefsView()),
  HomeTopic(
    number: 3,
    title: 'Class tasarımı',
    builder: (_) => const ClassDesignView(),
  ),
  HomeTopic(
    number: 4,
    title: 'Collection',
    builder: (_) => const CollectionView(),
  ),
];
