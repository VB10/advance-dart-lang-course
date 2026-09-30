import 'package:dartadvance_examples/03_class_modifiers/analytics_event.dart';
import 'package:dartadvance_examples/03_class_modifiers/analytics_logger.dart';
import 'package:test/test.dart';

void main() {
  test('known events get their own log line', () {
    expect(logLine(const ScreenViewed('home')), 'screen_view:home');
    expect(logLine(const ButtonTapped('buy')), 'tap:buy');
  });

  test('a subtype added later falls into the required default case', () {
    expect(logLine(const PurchaseCompleted(999)), 'event:PurchaseCompleted');
  });
}
