typedef Validator<T> = String? Function(T? value);

String? requiredText(String? value) => (value == null || value.isEmpty) ? 'Required' : null;

Validator<String> minLength(int min) =>
    (value) => (value ?? '').length < min ? 'At least $min characters' : null;

Validator<T> combine<T>(List<Validator<T>> validators) => (value) {
  for (final validate in validators) {
    final error = validate(value);
    if (error != null) return error;
  }
  return null;
};

final class LoginFormState {
  LoginFormState({required this.validatePassword});

  final Validator<String> validatePassword;
  String? passwordError;

  bool submit(String? password) {
    passwordError = validatePassword(password);
    return passwordError == null;
  }
}
