import 'dart:isolate';

int slowFib(int n) => n <= 1 ? 1 : slowFib(n - 1) + slowFib(n - 2);

Future<int> fib(int n) => Isolate.run(() => slowFib(n));
