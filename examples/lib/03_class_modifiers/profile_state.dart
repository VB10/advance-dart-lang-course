import '../00_architecture/result.dart';
import 'profile.dart';

sealed class ProfileState {
  const ProfileState();
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.profile);
  final Profile profile;
}

final class ProfileError extends ProfileState {
  const ProfileError(this.failure);
  final Failure failure;
}
