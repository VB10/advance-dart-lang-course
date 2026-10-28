/// Çalma listesi değişikliklerini kaydeden geçmiş; `with` ve `extends` ile kullanılır.
mixin class PlaylistHistory {
  final List<String> _entries = [];

  void record(String entry) => _entries.add(entry);

  // Olumsuz: iç listeyi olduğu gibi verir; dışarıdan `clear()` tüm geçmişi siler.
  List<String> get entriesWrong => _entries;

  // Olumlu: `List.unmodifiable` kopya verir; `clear()` UnsupportedError atar, geçmiş korunur.
  List<String> get entries => List.unmodifiable(_entries);
}
