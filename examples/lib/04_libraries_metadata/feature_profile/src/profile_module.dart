import 'data/in_memory_profile_repository.dart';
import 'domain/get_profile.dart';
import 'domain/profile.dart';

/// The only exported function that knows the data implementation.
GetProfile createGetProfile({Map<int, Profile> seed = const {}}) =>
    GetProfile(InMemoryProfileRepository(Map.of(seed)));
