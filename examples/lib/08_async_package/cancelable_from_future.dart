import 'package:async/async.dart' hide Result;

/// Cancelling discards the result; the request itself keeps running.
CancelableOperation<String> fetchCancelable(Future<String> request, {void Function()? onCancel}) =>
    CancelableOperation.fromFuture(request, onCancel: onCancel);

Future<String> describe(CancelableOperation<String> operation) async {
  final value = await operation.valueOrCancellation();
  return value ?? 'cancelled';
}
