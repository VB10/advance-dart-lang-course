import 'store.dart';

final class CounterStore extends Store<int> {
  CounterStore() : super(0);

  int disposeCalls = 0;

  void increment() => emit(state + 1); // Allowed: a subclass, on `this`.

  @override
  void dispose() {
    disposeCalls++;
    super.dispose(); // Required by @mustCallSuper.
  }
}
