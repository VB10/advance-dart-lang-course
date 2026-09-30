import 'package:async/async.dart' hide Result;

Stream<String> labelled(Stream<String> names, Stream<int> scores) =>
    StreamZip<Object>([names, scores]).map((pair) => '${pair[0]}=${pair[1]}');
