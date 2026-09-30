import 'package:meta/meta.dart';

@immutable
final class Profile {
  const Profile({required this.id, required this.displayName});
  final int id;
  final String displayName;
}
