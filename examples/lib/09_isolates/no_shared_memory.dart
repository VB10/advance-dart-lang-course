import 'dart:isolate';

int requestCount = 0;

Future<int> incrementInIsolate() => Isolate.run(() => ++requestCount);
