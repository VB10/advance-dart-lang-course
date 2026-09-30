import 'package:dartadvance_examples/05_collection/practice/ex3_playlist.dart';
import 'package:test/test.dart';

void main() {
  test('@immutable alone does not stop the list from changing', () {
    final source = ['t1'];
    final leaky = LeakyPlaylist(source);
    source.add('t2');

    expect(leaky.trackIds, ['t1', 't2']);
    leaky.trackIds.add('t3');
    expect(leaky.trackIds, hasLength(3));
  });

  test('Playlist copies its input, rejects writes and returns new instances', () {
    final source = ['t1'];
    final playlist = Playlist(source);
    source.add('t2');

    expect(playlist.trackIds, ['t1']);
    expect(() => playlist.trackIds.add('t3'), throwsUnsupportedError);
    expect(playlist.withTrack('t2').trackIds, ['t1', 't2']);
    expect(playlist.trackIds, ['t1']);
  });

  test('content equality has a matching hashCode and respects order', () {
    expect(Playlist(['a', 'b']), Playlist(['a', 'b']));
    expect(Playlist(['a', 'b']).hashCode, Playlist(['a', 'b']).hashCode);
    expect(Playlist(['a', 'b']) == Playlist(['b', 'a']), isFalse);
    expect({
      Playlist(['a']),
      Playlist(['a']),
    }, hasLength(1));
    expect(const LeakyPlaylist(['a']) == LeakyPlaylist(['a']), isFalse);
  });
}
