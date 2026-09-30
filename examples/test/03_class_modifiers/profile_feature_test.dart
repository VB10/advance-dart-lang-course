import 'package:dartadvance_examples/00_architecture/result.dart';
import 'package:dartadvance_examples/03_class_modifiers/get_profile.dart';
import 'package:dartadvance_examples/03_class_modifiers/in_memory_profile_repository.dart';
import 'package:dartadvance_examples/03_class_modifiers/profile.dart';
import 'package:dartadvance_examples/03_class_modifiers/profile_notifier.dart';
import 'package:dartadvance_examples/03_class_modifiers/profile_state.dart';
import 'package:dartadvance_examples/03_class_modifiers/profile_view.dart';
import 'package:test/test.dart';

void main() {
  const ada = Profile(id: 1, displayName: 'Ada');
  late InMemoryProfileRepository repository;
  late ProfileNotifier notifier;
  late List<ProfileState> emitted;

  setUp(() {
    repository = InMemoryProfileRepository({1: ada});
    notifier = ProfileNotifier(GetProfile(repository));
    emitted = [];
    notifier.addListener(emitted.add);
  });

  test('a new notifier starts in ProfileInitial', () {
    expect(notifier.state, isA<ProfileInitial>());
    expect(render(notifier.state), 'Tap to load');
  });

  test('loading a known id emits Loading then Loaded', () async {
    await notifier.load(1);
    expect(emitted.map((state) => state.runtimeType), [ProfileLoading, ProfileLoaded]);
    expect(render(notifier.state), 'Hi, Ada');
  });

  test('loading while offline ends in Error with a NetworkFailure', () async {
    repository.online = false;
    await notifier.load(1);
    expect(emitted.first, isA<ProfileLoading>());
    expect(notifier.state, isA<ProfileError>());
    expect(render(notifier.state), 'You are offline');
  });

  test('loading an unknown id ends in Error with ServerFailure(404)', () async {
    await notifier.load(99);
    expect(render(notifier.state), 'Server error (404)');
  });

  test('render handles every sealed state and failure', () {
    expect(render(const ProfileLoading()), 'Loading...');
    expect(
      render(ProfileError(UnexpectedFailure(StateError('x'), StackTrace.empty))),
      'Something went wrong',
    );
  });

  test('a removed listener stops receiving states', () async {
    notifier.removeListener(emitted.add);
    await notifier.load(1);
    expect(emitted, isEmpty);
    expect(notifier.state, isA<ProfileLoaded>());
  });

  test('the use case returns the repository Result unchanged', () async {
    final result = await GetProfile(repository)(1);
    expect(result, isA<Ok<Profile>>());
  });
}
