// Düzelt: /dartadvance Projemde başlık+gövde sırayla okunan stream parse yerlerini bul,
//    StreamQueue (package:async) ile düzelt, her biri için test yaz.
// Üret: /dartadvance Bana ilk satırı 'FATURA 3' gibi kalem sayısı, sonra o kadar satırı
//    okuyan bir fatura parser'ı yaz.
import 'package:async/async.dart' hide Result;

Future<List<String>> readItemsNaive(Stream<String> lines) async {
  await lines.first;
  return lines.take(2).toList(); // StateError: stream already listened to
}

Future<({String title, List<String> items})> readMessage(Stream<String> lines) async {
  final queue = StreamQueue(lines);
  try {
    final header = await queue.next;
    final [title, count] = header.split(' ');
    final items = await queue.take(int.parse(count));
    return (title: title, items: items); // 'ORDER 2' -> 2 items
  } finally {
    await queue.cancel();
  }
}
