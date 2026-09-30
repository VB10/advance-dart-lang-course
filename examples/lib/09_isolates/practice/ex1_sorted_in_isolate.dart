import 'dart:isolate';

/// Sorts a copy in place: the caller's list is left untouched.
Future<List<int>> sortedInIsolate(List<int> numbers) =>
    Isolate.run(() => _sortInPlace(numbers), debugName: 'sortedInIsolate');

List<int> _sortInPlace(List<int> numbers) {
  if (numbers.isEmpty) throw ArgumentError.value(numbers, 'numbers', 'must not be empty');
  return numbers..sort();
}
