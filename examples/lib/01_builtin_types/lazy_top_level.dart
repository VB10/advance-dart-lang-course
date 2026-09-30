int configReads = 0;

int _loadConfig() {
  configReads++;
  return 30;
}

final class AppConfig {
  static final int timeoutSeconds = _loadConfig(); // Lazy without `late`.
}
