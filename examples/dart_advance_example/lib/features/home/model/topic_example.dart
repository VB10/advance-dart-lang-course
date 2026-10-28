import 'package:flutter/widgets.dart';

/// One page of a topic: the same screen built the wrong way and the right way.
final class TopicExample {
  const TopicExample({
    required this.title,
    required this.negative,
    required this.positive,
  });

  final String title;

  /// The screen piece as the wrong code renders it.
  final Widget negative;

  /// The same screen piece with the rule applied.
  final Widget positive;
}
