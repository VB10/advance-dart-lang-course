/// Public API of the profile feature: consumers import ONLY this file.
@FeatureApi('profile')
library;

import '../metadata/feature_api.dart';

export 'src/domain/get_profile.dart' show GetProfile;
export 'src/domain/profile.dart' show Profile;
export 'src/domain/profile_repository.dart' show ProfileRepository;
export 'src/profile_module.dart' show createGetProfile;
