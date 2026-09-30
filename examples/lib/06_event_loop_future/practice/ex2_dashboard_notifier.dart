import 'dart:async';

import '../../00_architecture/result.dart';
import '../../00_architecture/user_feature.dart' show UserId;
import 'ex2_dashboard_domain.dart';

sealed class DashboardState {
  const DashboardState();
}

final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

final class DashboardReady extends DashboardState {
  const DashboardReady(this.dashboard);
  final Dashboard dashboard;
}

final class DashboardError extends DashboardState {
  const DashboardError(this.message);
  final String message;
}

final class DashboardNotifier {
  DashboardNotifier(this._repository);
  final DashboardRepository _repository;

  DashboardState state = const DashboardLoading();

  void start(UserId id) => unawaited(load(id));

  Future<void> load(UserId id) async {
    state = const DashboardLoading();
    state = switch (await _repository.load(id)) {
      Ok(:final value) => DashboardReady(value),
      Err(:final failure) => DashboardError(failure.message),
    };
  }
}

String dashboardTitle(DashboardState state) => switch (state) {
  DashboardLoading() => 'Loading...',
  DashboardReady(dashboard: Dashboard(:final userName, unread: final int count)) =>
    '$userName ($count)',
  DashboardReady(dashboard: Dashboard(:final userName)) => userName,
  DashboardError(:final message) => message,
};
