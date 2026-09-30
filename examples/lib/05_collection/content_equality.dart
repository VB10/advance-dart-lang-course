import 'package:collection/collection.dart';

Map<String, List<String>> _freshTags() => {
  'tags': ['a', 'b'],
};

({bool list, bool set, bool map, bool deep, bool unorderedList}) contentEquality() => (
  list: const ListEquality<int>().equals([1, 2], [1, 2]),
  set: const SetEquality<int>().equals({1, 2}, {2, 1}),
  map: const MapEquality<String, int>().equals({'a': 1}, {'a': 1}),
  deep: const DeepCollectionEquality().equals(_freshTags(), _freshTags()),
  unorderedList: const DeepCollectionEquality.unordered().equals([1, 2], [2, 1]),
);
