import 'dart:collection';

({List<int> view, List<int> copy}) viewVsCopy() {
  final source = <int>[1, 2];
  final view = UnmodifiableListView<int>(source);
  final copy = List<int>.unmodifiable(source);
  source.add(3);
  return (view: view, copy: copy);
}
