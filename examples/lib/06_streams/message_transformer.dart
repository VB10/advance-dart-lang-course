// Düzelt: /dartadvance Projemde stream olaylarını döngüyle süzüp dönüştüren yerleri bul,
//    `StreamTransformer.fromHandlers` ile dönüştür, test yaz.
// Üret: /dartadvance Bana fatura satırı metinlerini kırpıp boşları atan, kalanları büyük
//    harfe çeviren bir stream dönüştürücü yaz.
import 'dart:async';

Future<List<String>> trimWrong(Stream<String> source) async {
  final result = <String>[];
  await for (final message in source) {
    if (message.trim().isNotEmpty) result.add(message.trim());
  }
  return result; // open stream: completes only when the source closes
}

final trimMessages = StreamTransformer<String, String>.fromHandlers(
  handleData: (message, sink) {
    final trimmed = message.trim();
    if (trimmed.isNotEmpty) sink.add(trimmed); // ['  hi ', '   ', 'yo'] -> ['hi', 'yo']
  },
);
