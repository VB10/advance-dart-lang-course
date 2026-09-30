final class NotificationModel {
  const NotificationModel({required this.type, required this.show, required this.on});

  final String type; // Built-in identifier: fine as a field, not as a type name.
  final bool show;
  final DateTime on;
}
