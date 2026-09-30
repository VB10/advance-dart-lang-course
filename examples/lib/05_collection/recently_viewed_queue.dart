import 'dart:collection';

final class RecentlyViewed {
  RecentlyViewed(this.capacity);
  final int capacity;
  final Queue<String> _items = Queue<String>();

  void view(String id) {
    _items
      ..remove(id)
      ..addFirst(id);
    if (_items.length > capacity) _items.removeLast();
  }

  List<String> get items => _items.toList();
}
