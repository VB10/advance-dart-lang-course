import 'package:async/async.dart' hide Result;

/// Listening to [watch] listens to both sources; cancelling cancels both.
final class InboxDataSource {
  const InboxDataSource({required this.push, required this.localEdits});
  final Stream<Map<String, Object?>> push;
  final Stream<Map<String, Object?>> localEdits;

  Stream<Map<String, Object?>> watch() => StreamGroup.merge([push, localEdits]);
}
