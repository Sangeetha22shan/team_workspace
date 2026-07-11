class AppConfig {
  final String apiBaseUrl;

  AppConfig._(this.apiBaseUrl);

  /// Creates AppConfig reading from compile-time dart-define.
  /// Provide API_BASE_URL when building/running for production.
  factory AppConfig.fromEnvironment() {
    const defaultUrl = 'https://jsonplaceholder.typicode.com';
    final url = const String.fromEnvironment('API_BASE_URL', defaultValue: defaultUrl);
    return AppConfig._(url);
  }
}

