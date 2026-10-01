// /dartadvance Projemde stream olaylarını döngüyle süzüp dönüştüren yerleri bul,
// `StreamTransformer.fromHandlers` ile dönüştür, her biri için test yaz.
import 'dart:async';

final trimMessages = StreamTransformer<String, String>.fromHandlers(
  handleData: (message, sink) {
    final trimmed = message.trim();
    if (trimmed.isNotEmpty) sink.add(trimmed); // ['  hi ', '   ', 'yo'] -> ['hi', 'yo']
  },
);
