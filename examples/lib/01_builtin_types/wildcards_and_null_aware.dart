// /dartadvance Projemde `if (x != null)` ile null kontrolü yapıp atama veya liste
// birleştirme yapan yerleri bul, `?..` ve `...?` ile sadeleştir, her biri için test yaz.

final class Cart {
  String? note;
}

Cart? withNoteVerbose(Cart? cart, String note) {
  if (cart != null) cart.note = note;
  return cart;
}

Cart? withNote(Cart? cart, String note) => cart?..note = note; // null in: null out

List<String> allTags(List<String> base, List<String>? extra) => [
  ...base,
  ...?extra, // null extra adds nothing
];

// Since Dart 3.7, several `_` parameters can coexist.
void Function(int, String) ignoreBoth = (_, _) {};
