import 'package:dart_advance_example/features/01_builtin_types/model/event_filter_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('late final freezes the first language, getter follows changes', () {
    final sheet = EventFilterSheet('tr');
    expect(sheet.titlesWrong, ['Bekleyen', 'Onaylanan', 'Reddedilen']);
    expect(sheet.titles, ['Bekleyen', 'Onaylanan', 'Reddedilen']);

    sheet.language = 'en';

    expect(sheet.titlesWrong, ['Bekleyen', 'Onaylanan', 'Reddedilen']);
    expect(sheet.titles, ['Pending', 'Approved', 'Declined']);
  });
}
