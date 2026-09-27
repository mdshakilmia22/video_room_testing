class APIConfig {
  APIConfig._();
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com/api/v1',
  );

  static const String agoraTokenUrl = '/agora/token';
}
