import 'dart:collection';

import 'package:dartadvance_examples/05_collection/recently_viewed_queue.dart';
import 'package:test/test.dart';

void main() {
  test('Queue() is a ListQueue working as a bounded buffer at both ends', () {
    expect(Queue<int>(), isA<ListQueue<int>>());
    final recent = RecentlyViewed(2)
      ..view('a')
      ..view('b')
      ..view('a')
      ..view('c');
    expect(recent.items, ['c', 'a']);
  });
}
