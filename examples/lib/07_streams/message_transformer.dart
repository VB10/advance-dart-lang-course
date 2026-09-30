import 'dart:async';

/// Trims each chat message and drops the empty ones.
final trimMessages = StreamTransformer<String, String>.fromHandlers(
  handleData: (message, sink) {
    final trimmed = message.trim();
    if (trimmed.isNotEmpty) sink.add(trimmed);
  },
);
