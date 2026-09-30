import 'package:async/async.dart' as async_pkg show Result;

Future<async_pkg.Result<int>> captureCount(Future<int> request) =>
    async_pkg.Result.capture(request);

Future<int> releaseCount(Future<async_pkg.Result<int>> captured) =>
    async_pkg.Result.release(captured);
