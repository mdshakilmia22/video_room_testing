import 'api_service.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient _instance = ApiClient._();

  factory ApiClient() => _instance;

  Map<String, String>? _defaultQueryParams;

  void setDefaultQueryParams(Map<String, String>? params) {
    _defaultQueryParams = params;
  }

  ApiService get api => ApiService(defaultQueryParams: _defaultQueryParams);

  ApiService apiWithToken(String? token) =>
      ApiService(token: token, defaultQueryParams: _defaultQueryParams);
}
