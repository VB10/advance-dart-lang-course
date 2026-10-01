// Skill'e ver: "Projemde tekrar tekrar yüklenen config/liste yerlerini bul,
// AsyncMemoizer (package:async) ile tek seferlik yap, her biri için test yaz."
import 'package:async/async.dart' hide Result;

final class ConfigLoader {
  ConfigLoader(this._load);
  final Future<Map<String, String>> Function() _load;
  final _memo = AsyncMemoizer<Map<String, String>>();

  Future<Map<String, String>> get configNaive => _load(); // 3 callers: 3 loads

  Future<Map<String, String>> get config => _memo.runOnce(_load); // 3 callers: 1 load

  bool get hasLoaded => _memo.hasRun; // a failure is memoized too, forever
}
