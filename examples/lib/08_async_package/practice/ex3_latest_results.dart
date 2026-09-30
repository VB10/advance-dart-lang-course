import 'dart:async';

import 'package:async/async.dart' hide Result;

/// Emits only the result of the latest query ("switch map").
Stream<R> latestResults<Q, R extends Object>(
  Stream<Q> queries,
  CancelableOperation<R> Function(Q query) run,
) => _LatestResults(queries, run).output.stream;

final class _LatestResults<Q, R extends Object> {
  _LatestResults(this._queries, this._run) {
    output = StreamController<R>(
      onListen: _listen,
      onPause: () => _source?.pause(),
      onResume: () => _source?.resume(),
      onCancel: _cancel,
    );
  }
  final Stream<Q> _queries;
  final CancelableOperation<R> Function(Q query) _run;
  late final StreamController<R> output;
  StreamSubscription<Q>? _source;
  CancelableOperation<R>? _pending;
  var _sourceDone = false;

  void _listen() {
    _source = _queries.listen(_onQuery, onError: output.addError, onDone: _onSourceDone);
  }

  void _onQuery(Q query) {
    final previous = _pending;
    final operation = _pending = _run(query);
    unawaited(previous?.cancel());
    unawaited(_deliver(operation));
  }

  Future<void> _deliver(CancelableOperation<R> operation) async {
    try {
      final value = await operation.valueOrCancellation();
      if (value == null || !identical(_pending, operation)) return;
      _pending = null;
      output.add(value);
    } catch (error, stackTrace) {
      if (!identical(_pending, operation)) return;
      _pending = null;
      output.addError(error, stackTrace);
    }
    _closeIfIdle();
  }

  void _onSourceDone() {
    _sourceDone = true;
    _closeIfIdle();
  }

  void _closeIfIdle() {
    if (_sourceDone && _pending == null) unawaited(output.close());
  }

  Future<void> _cancel() async {
    await _source?.cancel();
    await _pending?.cancel();
  }
}
