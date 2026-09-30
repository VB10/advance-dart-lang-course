import 'dart:isolate';

Future<int> failInIsolate() => Isolate.run<int>(() => throw StateError('In a bad state!'));
