import '../00_architecture/result.dart';
import 'get_profile.dart';
import 'profile_state.dart';
import 'state_notifier.dart';

final class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(this._getProfile) : super(const ProfileInitial());
  final GetProfile _getProfile;

  Future<void> load(int id) async {
    emit(const ProfileLoading());
    final result = await _getProfile(id);
    emit(switch (result) {
      Ok(:final value) => ProfileLoaded(value),
      Err(:final failure) => ProfileError(failure),
    });
  }
}
