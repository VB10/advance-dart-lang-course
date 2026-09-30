import 'package:async/async.dart' hide Result;

/// Two live sources, one stream; closes after both have closed.
Stream<String> allAlerts(Stream<String> server, Stream<String> device) =>
    StreamGroup.merge([server, device]);

/// Every branch sees every event, even a single-subscription stream.
Future<(int count, int total)> countAndTotal(Stream<int> prices) async {
  final [forCount, forTotal] = StreamSplitter.splitFrom(prices);
  return (forCount.length, forTotal.fold(0, (sum, price) => sum + price)).wait;
}
