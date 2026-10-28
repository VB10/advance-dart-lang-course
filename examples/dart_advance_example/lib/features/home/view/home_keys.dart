import 'package:flutter/widgets.dart';

abstract final class HomeKeys {
  static const ValueKey<String> empty = ValueKey('home_empty');
  static const ValueKey<String> list = ValueKey('home_list');

  static ValueKey<String> topic(int number) => ValueKey('home_topic_$number');
}
