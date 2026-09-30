import 'dart:async';

import 'package:async/async.dart' hide Result;

CancelableOperation<int> slowSquare(int n, {required Duration delay}) {
  late final Timer timer;
  final completer = CancelableCompleter<int>(onCancel: () => timer.cancel());
  timer = Timer(delay, () => completer.complete(n * n));
  return completer.operation;
}
