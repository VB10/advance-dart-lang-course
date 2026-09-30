import 'analytics_event.dart';

String logLine(AnalyticsEvent event) => switch (event) {
  ScreenViewed(:final screen) => 'screen_view:$screen',
  ButtonTapped(:final buttonId) => 'tap:$buttonId',
  _ => 'event:${event.runtimeType}', // Required: the root is `final`, not `sealed`.
};
