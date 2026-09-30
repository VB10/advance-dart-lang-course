import 'package:dartadvance_examples/09_isolates/practice/ex3_primes_in_isolate.dart';
import 'package:test/test.dart';

void main() {
  test('a finite worker streams every prime, closes and exits', () async {
    final (:primes, :exited) = primesInIsolate(limit: 30);
    expect(await primes.toList(), [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]);
    await exited.timeout(const Duration(seconds: 2));
  });

  test('cancelling an endless worker kills the isolate', () async {
    final (:primes, :exited) = primesInIsolate();
    var didExit = false;
    exited.then((_) => didExit = true).ignore();
    expect(didExit, isFalse);

    expect(await primes.take(4).toList(), [2, 3, 5, 7]);
    await exited.timeout(const Duration(seconds: 2));
    expect(didExit, isTrue);
  });
}
