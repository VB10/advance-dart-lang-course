import '../../00_architecture/result.dart';
import '../../00_architecture/user_feature.dart' show UserId;

final class Dashboard {
  const Dashboard({required this.userName, required this.unread});
  final String userName;

  /// `null` when the optional unread badge could not be loaded.
  final int? unread;
}

abstract interface class DashboardRepository {
  Future<Result<Dashboard>> load(UserId id);
}
