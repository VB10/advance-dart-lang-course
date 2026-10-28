import 'package:dart_advance_example/features/01_builtin_types/model/locate_button.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('! throws when the map is not ready', () {
    expect(
      () => LocateButton().onTapWrong('Kadıköy'),
      throwsA(isA<TypeError>()),
    );
  });

  test('?.. skips the whole chain until the map is ready', () {
    final button = LocateButton()..onTap('Kadıköy');
    expect(button.camera, isNull);

    button
      ..camera = MapCamera()
      ..onTap('Kadıköy');
    expect(button.camera?.target, 'Kadıköy');
    expect(button.camera?.pin, 'Kadıköy');
  });
}
