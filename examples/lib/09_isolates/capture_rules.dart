// /dartadvance Projemde `Isolate.run`/`compute` closure'larını bul, ne yakaladıklarını
// ve global duruma bağımlılığı `dart:isolate` kurallarıyla düzelt, her biri için test yaz.
import 'dart:isolate';

int loadedOrderCount = 0;

// The list is copied into the isolate: the caller's list stays unsorted.
Future<List<int>> sortedTotals(List<int> totals) => Isolate.run(() => totals..sort());

// A global is a separate variable in the new isolate.
Future<int> countInIsolate() => Isolate.run(() => ++loadedOrderCount); // 1, main stays 0

Future<int> captureReceivePort() async {
  final port = ReceivePort();
  try {
    return await Isolate.run(() => port.hashCode); // ArgumentError: unsendable
  } finally {
    port.close();
  }
}
