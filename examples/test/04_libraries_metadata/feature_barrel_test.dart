import 'package:dartadvance_examples/00_architecture/result.dart';
import 'package:dartadvance_examples/04_libraries_metadata/feature_profile/profile.dart';
import 'package:dartadvance_examples/04_libraries_metadata/metadata/feature_api.dart';
import 'package:test/test.dart';

final class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<Result<Profile>> fetch(int id) async => Ok(Profile(id: id, displayName: 'Fake'));
}

void main() {
  test('the exported factory wires the hidden data implementation', () async {
    final getProfile = createGetProfile(seed: {1: const Profile(id: 1, displayName: 'Ada')});

    expect(await getProfile(1), isA<Ok<Profile>>());
    expect(
      await getProfile(2),
      isA<Err<Profile>>().having((err) => err.failure, 'failure', isA<ServerFailure>()),
    );
  });

  test('consumers can substitute the exported interface', () async {
    final result = await GetProfile(_FakeProfileRepository())(3);
    expect((result as Ok<Profile>).value.displayName, 'Fake');
  });

  test('the barrel carries a library-level custom annotation type', () {
    expect(const FeatureApi('profile').name, 'profile');
  });
}
