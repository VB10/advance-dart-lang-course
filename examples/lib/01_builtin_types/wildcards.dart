int countCallbacks(List<void Function(int, String)> callbacks) {
  var calls = 0;
  for (final _ in callbacks) {
    calls++;
  }
  return calls;
}

final List<int> sizes = ['a', 'bb'].map((_) => 0).toList();

void Function(int, String) ignoreBoth = (_, _) {};
