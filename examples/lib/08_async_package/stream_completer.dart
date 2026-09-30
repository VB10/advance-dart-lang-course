import 'package:async/async.dart' hide Result;

Stream<int> ticksAfterConnect(Future<Stream<int>> connect) => StreamCompleter.fromFuture(connect);
