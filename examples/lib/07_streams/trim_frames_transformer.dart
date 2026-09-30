import 'dart:async';

final trimFrames = StreamTransformer<String, String>.fromHandlers(
  handleData: (frame, sink) {
    final trimmed = frame.trim();
    if (trimmed.isNotEmpty) sink.add(trimmed);
  },
);
