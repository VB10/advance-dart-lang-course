import '../00_architecture/result.dart';
import 'profile.dart';
import 'profile_state.dart';

String render(ProfileState state) => switch (state) {
  ProfileInitial() => 'Tap to load',
  ProfileLoading() => 'Loading...',
  ProfileLoaded(profile: Profile(:final displayName)) => 'Hi, $displayName',
  ProfileError(failure: NetworkFailure()) => 'You are offline',
  ProfileError(failure: ServerFailure(:final statusCode)) => 'Server error ($statusCode)',
  ProfileError(failure: UnexpectedFailure()) => 'Something went wrong',
};
