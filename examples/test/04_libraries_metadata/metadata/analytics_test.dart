import 'package:dartadvance_examples/04_libraries_metadata/metadata/analytics.dart';
import 'package:test/test.dart';

void main() {
  test('an @awaitNotRequired future may be dropped by the caller', () async {
    final analytics = Analytics();
    analytics.track('opened');
    await Future<void>.delayed(Duration.zero);

    expect(analytics.sent, ['opened']);
  });
}
