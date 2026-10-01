// Düzelt: /dartadvance Projemde `List`/`Map` alanlı sınıflarda `==`/`hashCode` yazan
//    yerleri bul, `DeepCollectionEquality` ile düzelt, her biri için test yaz.
// Üret: /dartadvance Bana etiket listesi ve özellik haritası tutan, aynı içerikte eşit
//    sayılan bir `Playlist` sınıfı yaz.
import 'package:collection/collection.dart';

const _tagEquality = DeepCollectionEquality();

bool naiveSame(Map<String, List<String>> a, Map<String, List<String>> b) =>
    a == b; // same content: false

bool deepSame(Map<String, List<String>> a, Map<String, List<String>> b) =>
    _tagEquality.equals(a, b); // same content: true

final class Profile {
  Profile(this.name, this.tags);

  final String name;
  final Map<String, List<String>> tags;

  @override
  bool operator ==(Object other) =>
      other is Profile && other.name == name && _tagEquality.equals(other.tags, tags);

  @override
  int get hashCode => Object.hash(name, _tagEquality.hash(tags));
}

bool sameQuery(Map<String, List<String>> a, Map<String, List<String>> b) =>
    const DeepCollectionEquality.unordered().equals(a, b);
