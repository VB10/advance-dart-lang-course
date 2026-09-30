import 'package:async/async.dart' hide Result;

Stream<String> lazyLogLines(Stream<String> Function() openLog) => LazyStream(openLog);
