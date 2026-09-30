import 'package:meta/meta.dart';

final class Analytics {
  final List<String> sent = [];

  /// Never fails and its value needs no handling, so callers may drop it.
  @awaitNotRequired
  Future<void> track(String event) async {
    sent.add(event);
  }
}
