import 'future_chain.dart';

Future<String> longChainAwait(List<String> log) async {
  int value;
  try {
    await one();
    final text = await two();
    await three();
    value = text.length;
  } catch (error) {
    log.add('Got error: $error');
    value = 42;
  }
  return 'The value is $value';
}
