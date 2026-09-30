sealed class DownloadEvent {
  const DownloadEvent();
}

final class DownloadProgress extends DownloadEvent {
  const DownloadProgress(this.received, this.total);
  final int received;
  final int total;
}

final class DownloadDone extends DownloadEvent {
  const DownloadDone(this.bytes);
  final int bytes;
}

final class DownloadFailed extends DownloadEvent {
  const DownloadFailed(this.error);
  final Object error;
}

/// A source error becomes a final `DownloadFailed` data event.
Stream<DownloadEvent> trackDownload(Stream<List<int>> chunks, {required int total}) async* {
  var received = 0;
  try {
    await for (final chunk in chunks) {
      received += chunk.length;
      yield DownloadProgress(received, total);
    }
    yield DownloadDone(received);
  } catch (error) {
    yield DownloadFailed(error);
  }
}

String describeDownload(DownloadEvent event) => switch (event) {
  DownloadProgress(:final received, :final total) => '$received/$total',
  DownloadDone(:final bytes) => 'done $bytes',
  DownloadFailed() => 'failed',
};
