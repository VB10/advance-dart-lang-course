import '../00_architecture/user_feature.dart' show UserId;

typedef UserTapCallback = void Function(UserId id);
typedef Validator<T> = String? Function(T? value);

final class UserListController {
  UserListController({required this.onTap, this.validateQuery});

  final UserTapCallback onTap;
  final Validator<String>? validateQuery;

  String? search(String? query) => validateQuery?.call(query);
}
