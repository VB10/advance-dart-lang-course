// Skill'e ver: "Projemde sayfaları hepsini çekip listeye dönen yerleri bul, `async*` ile
// tembel Stream'e çevir, erken iptalde temizliği de kapsayan test yaz."

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
