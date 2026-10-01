// Düzelt: /dartadvance Projemde sayfaları hepsini çekip listeye dönen yerleri bul,
//    `async*` ile tembel Stream'e çevir, erken iptali de kapsayan test yaz.
// Üret: /dartadvance Bana sayfa sayfa gelen ürün yorumlarını akıtan, ilk 5'te bırakılınca
//    bağlantıyı kapatan bir fonksiyon yaz.

Future<List<int>> naiveOrderIds(Future<List<int>> Function(int page) fetchPage) async {
  final all = <int>[];
  for (var page = 0; ; page++) {
    final ids = await fetchPage(page);
    if (ids.isEmpty) return all;
    all.addAll(ids); // eager: caller wants 3 ids, every page is still fetched
  }
}

Stream<int> orderIds(
  Future<List<int>> Function(int page) fetchPage, {
  required void Function() onReleased,
}) async* {
  try {
    for (var page = 0; ; page++) {
      final ids = await fetchPage(page);
      if (ids.isEmpty) return;
      yield* Stream.fromIterable(ids); // take(3) over 2-id pages: only pages 0, 1 fetched
    }
  } finally {
    onReleased(); // runs once, even on early stop
  }
}
