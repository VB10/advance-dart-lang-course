// Düzelt: /dartadvance Projemde stream olaylarını döngüyle süzüp dönüştüren yerleri bul,
//    `StreamTransformer.fromHandlers` ile dönüştür, test yaz.
// Üret: /dartadvance Bana fatura satırı metinlerini kırpıp boşları atan, kalanları büyük
//    harfe çeviren bir stream dönüştürücü yaz.
import 'dart:async';

final trimMessages = StreamTransformer<String, String>.fromHandlers(
  handleData: (message, sink) {
    final trimmed = message.trim();
    if (trimmed.isNotEmpty) sink.add(trimmed); // ['  hi ', '   ', 'yo'] -> ['hi', 'yo']
  },
);
