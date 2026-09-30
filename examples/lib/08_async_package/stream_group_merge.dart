import 'package:async/async.dart' hide Result;

Stream<String> allAlerts(Stream<String> server, Stream<String> device) =>
    StreamGroup.merge([server, device]);
