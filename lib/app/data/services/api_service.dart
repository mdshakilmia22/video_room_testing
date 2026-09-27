import 'dart:async';
import 'dart:convert';

import 'package:agora_video_call_test/app/core/core_export.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  ApiException({required this.statusCode, required this.message});

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({this.token, this.defaultQueryParams});

  static const _timeout = Duration(seconds: 30);

  final String? token;
  final Map<String, String>? defaultQueryParams;

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Uri _buildUri(String path) {
    final uri = Uri.parse('${APIConfig.baseUrl}$path');
    final queryParams = defaultQueryParams;
    if (queryParams == null || queryParams.isEmpty) return uri;
    final merged = Map<String, String>.from(uri.queryParameters);
    for (final entry in queryParams.entries) {
      if (!merged.containsKey(entry.key)) merged[entry.key] = entry.value;
    }
    return uri.replace(queryParameters: merged);
  }

  Future<Map<String, dynamic>> get(String path) async {
    final response = await http
        .get(_buildUri(path), headers: _headers)
        .timeout(_timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http
        .post(
          _buildUri(path),
          headers: {..._headers, 'Content-Type': 'application/json'},
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(_timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http
        .put(
          _buildUri(path),
          headers: {..._headers, 'Content-Type': 'application/json'},
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(_timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final response = await http
        .delete(_buildUri(path), headers: _headers)
        .timeout(_timeout);
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Invalid response from server',
      );
    }
    final body = decoded;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    final message = (body['message'] as String?) ?? 'Something went wrong';
    throw ApiException(statusCode: response.statusCode, message: message);
  }
}
