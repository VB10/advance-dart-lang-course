import 'package:dart_advance_example/features/03_class_design/model/playlist_history.dart';
import 'package:flutter_test/flutter_test.dart';

class _Mixed with PlaylistHistory {}

class _Extended extends PlaylistHistory {}

void main() {
  test('works with both with and extends', () {
    final mixed = _Mixed()..record('a');
    final extended = _Extended()..record('b');
    expect(mixed.entries, ['a']);
    expect(extended.entries, ['b']);
  });

  test('exposed list is mutable only in the wrong version', () {
    final wrong = PlaylistHistory()..record('a');
    final right = PlaylistHistory()..record('a');
    wrong.entriesWrong.clear();
    expect(wrong.entriesWrong, isEmpty);
    expect(() => right.entries.clear(), throwsUnsupportedError);
    expect(right.entries, ['a']);
  });
}
