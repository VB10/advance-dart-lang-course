import 'package:dartadvance_examples/04_libraries_metadata/metadata/money.dart';
import 'package:test/test.dart';

void main() {
  test('@immutable const instances are canonicalized', () {
    expect(identical(const Money(100, 'TRY'), const Money(100, 'TRY')), isTrue);
  });

  test('@useResult add returns a new value and leaves the original unchanged', () {
    const total = Money(100, 'TRY');
    final withFee = total.add(const Money(25, 'TRY'));

    expect(withFee.cents, 125);
    expect(total.cents, 100);
    expect(() => total.add(const Money(1, 'EUR')), throwsArgumentError);
  });
}
