import 'package:async/async.dart' hide Result;

Future<(int count, int sum)> countAndSum(Stream<int> source) async {
  final [forCount, forSum] = StreamSplitter.splitFrom(source);
  return (forCount.length, forSum.fold(0, (a, b) => a + b)).wait;
}
