import 'package:collection/collection.dart';

QueueList<String> history() => QueueList<String>()
  ..add('b')
  ..addFirst('a')
  ..add('c');
