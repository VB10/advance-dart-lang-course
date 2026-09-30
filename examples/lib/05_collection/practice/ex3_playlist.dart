import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// Passes the analyzer, yet whoever holds the source list can still change it.
@immutable
final class LeakyPlaylist {
  const LeakyPlaylist(this.trackIds);
  final List<String> trackIds;
}

@immutable
final class Playlist {
  Playlist(Iterable<String> trackIds) : trackIds = List.unmodifiable(trackIds);
  final List<String> trackIds;

  static const _tracksEquality = ListEquality<String>();

  @useResult
  Playlist withTrack(String id) => Playlist([...trackIds, id]);

  @override
  bool operator ==(Object other) =>
      other is Playlist && _tracksEquality.equals(other.trackIds, trackIds);

  @override
  int get hashCode => _tracksEquality.hash(trackIds);
}
