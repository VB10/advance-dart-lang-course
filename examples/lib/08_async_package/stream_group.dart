// /dartadvance Projemde aynı stream'i iki kez dinleyen yerleri bul, StreamSplitter ve
// StreamGroup (package:async) ile düzelt, her biri için test yaz.
import 'package:async/async.dart' hide Result;

Stream<String> allAlerts(Stream<String> server, Stream<String> device) =>
    StreamGroup.merge([server, device]); // closes after both have closed

Future<(int, int)> countAndTotalNaive(Stream<int> prices) async =>
    (prices.length, prices.fold(0, (sum, price) => sum + price)).wait; // StateError

Future<(int count, int total)> countAndTotal(Stream<int> prices) async {
  final [forCount, forTotal] = StreamSplitter.splitFrom(prices);
  return (forCount.length, forTotal.fold(0, (sum, price) => sum + price)).wait;
}
