/// Static application configuration.
///
/// The API base URL is injected at build time:
/// `flutter build web --dart-define=API_BASE_URL=https://your-api.onrender.com`
class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const int defaultPageSize = 10;
  static const List<int> pageSizes = [10, 20, 50];
  /// Newest registrations first, so a freshly added vehicle is immediately visible.
  static const String defaultSort = 'createdAt,desc';
}
