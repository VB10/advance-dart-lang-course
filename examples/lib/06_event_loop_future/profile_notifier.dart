import 'dart:async';

import '../00_architecture/result.dart';
import '../00_architecture/user_feature.dart' show UserId;
import 'profile_domain.dart';

sealed class ProfileState {
  const ProfileState();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.profile);
  final Profile profile;
}

final class ProfileError extends ProfileState {
  const ProfileError(this.message);
  final String message;
}

final class ProfileNotifier {
  ProfileNotifier(this._getProfile);
  final GetProfile _getProfile;

  ProfileState state = const ProfileLoading();

  /// Safe to fire and forget: [load] never throws, failures are a `Result`.
  void start(UserId id) => unawaited(load(id));

  Future<void> load(UserId id) async {
    state = const ProfileLoading();
    state = switch (await _getProfile(id)) {
      Ok(:final value) => ProfileLoaded(value),
      Err(:final failure) => ProfileError(failure.message),
    };
  }
}
