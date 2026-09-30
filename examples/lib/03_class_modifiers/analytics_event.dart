abstract final class AnalyticsEvent {
  const AnalyticsEvent();
}

final class ScreenViewed extends AnalyticsEvent {
  const ScreenViewed(this.screen);
  final String screen;
}

final class ButtonTapped extends AnalyticsEvent {
  const ButtonTapped(this.buttonId);
  final String buttonId;
}

/// Added in a later release; existing consumers keep compiling.
final class PurchaseCompleted extends AnalyticsEvent {
  const PurchaseCompleted(this.amountCents);
  final int amountCents;
}
