import 'package:async/async.dart' hide Result;

/// Runs [_load] once; a failure is memoized too, forever.
final class ConfigLoader {
  ConfigLoader(this._load);
  final Future<Map<String, String>> Function() _load;
  final _memo = AsyncMemoizer<Map<String, String>>();

  Future<Map<String, String>> get config => _memo.runOnce(_load);

  bool get hasLoaded => _memo.hasRun;
}
