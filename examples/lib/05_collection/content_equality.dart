import 'package:collection/collection.dart';

const _tagEquality = DeepCollectionEquality();

final class Profile {
  Profile(this.name, this.tags);

  final String name;
  final Map<String, List<String>> tags;

  @override
  bool operator ==(Object other) =>
      other is Profile && other.name == name && _tagEquality.equals(other.tags, tags);

  // hashCode must match ==, so it uses the same Equality.
  @override
  int get hashCode => Object.hash(name, _tagEquality.hash(tags));
}

bool sameQuery(Map<String, List<String>> a, Map<String, List<String>> b) =>
    const DeepCollectionEquality.unordered().equals(a, b);
