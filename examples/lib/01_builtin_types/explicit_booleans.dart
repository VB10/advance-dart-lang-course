bool shouldShowBadge(String label, int count, Object? error, double ratio) =>
    label.isNotEmpty && count != 0 && error == null && !ratio.isNaN;
