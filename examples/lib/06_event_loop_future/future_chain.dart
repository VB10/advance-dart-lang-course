Future<String> one() => Future.value('from one');
Future<String> two() => Future.error('error from two');
Future<String> three() => Future.value('from three');

int _logAndRecover(List<String> log, Object error) {
  log.add('Got error: $error');
  return 42;
}

Future<String> longChain(List<String> log) {
  return one()
      .then((_) => two())
      .then((_) => three()) // skipped: still two()'s error
      .then((value) => value.length) // skipped: still two()'s error
      .catchError((Object error) => _logAndRecover(log, error))
      .then((value) => 'The value is $value');
}
