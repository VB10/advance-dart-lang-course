import 'package:meta/meta_meta.dart';

/// Marks a library as a feature's public entry point (barrel).
@Target({TargetKind.library})
final class FeatureApi {
  const FeatureApi(this.name);
  final String name;
}
