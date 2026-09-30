import 'dart:isolate';

/// Worker entry point; yields between primes so a kill can be handled.
Future<void> primeWorker((int?, SendPort) message) async {
  final (limit, results) = message;
  for (var n = 2; limit == null || n <= limit; n++) {
    if (_isPrime(n)) results.send(n);
    await Future<void>.delayed(Duration.zero);
  }
  results.send(null);
}

bool _isPrime(int n) {
  for (var divisor = 2; divisor * divisor <= n; divisor++) {
    if (n % divisor == 0) return false;
  }
  return true;
}
