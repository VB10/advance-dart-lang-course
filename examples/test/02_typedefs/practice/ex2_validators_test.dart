import 'package:dartadvance_examples/02_typedefs/practice/ex2_validators.dart';
import 'package:test/test.dart';

void main() {
  test('a matching function is an instance of the typedef', () {
    expect(requiredText, isA<Validator<String>>());
    expect(minLength(3), isA<Validator<String>>());
  });

  test('combine returns the first error, null when all pass', () {
    final validate = combine<String>([requiredText, minLength(8)]);
    expect(validate(''), 'Required');
    expect(validate(null), 'Required');
    expect(validate('short'), 'At least 8 characters');
    expect(validate('long enough'), isNull);
  });

  test('LoginFormState exposes the error for the screen', () {
    final form = LoginFormState(validatePassword: combine([requiredText, minLength(8)]));
    expect(form.submit('abc'), isFalse);
    expect(form.passwordError, 'At least 8 characters');
    expect(form.submit('abcdefgh'), isTrue);
    expect(form.passwordError, isNull);
  });
}
