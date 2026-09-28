import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'api_exceptions.dart';
import 'api_response.dart';

/// ApiClient abstracts HTTP network operations conforming to the documented architecture.
class ApiClient {
  final http.Client _client;
  final String _baseUrl;
  String? _authToken;

  ApiClient({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConstants.baseUrl;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> _buildHeaders([Map<String, String>? extraHeaders]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$path').replace(
        queryParameters: queryParameters?.map((k, v) => MapEntry(k, v.toString())),
      );
      final response = await _client.get(uri, headers: _buildHeaders(headers));
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$path');
      final response = await _client.post(
        uri,
        headers: _buildHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$path');
      final response = await _client.patch(
        uri,
        headers: _buildHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$path');
      final response = await _client.put(
        uri,
        headers: _buildHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, String>? headers,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$path');
      final response = await _client.delete(
        uri,
        headers: _buildHeaders(headers),
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  ApiResponse<T> _handleResponse<T>(http.Response response, T Function(dynamic json)? fromJson) {
    final Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        'Invalid response format from server',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.fromJson(body, fromJson);
    } else if (response.statusCode == 401) {
      throw AuthException(
        body['message'] ?? 'Unauthorized access',
        statusCode: response.statusCode,
      );
    } else {
      throw ApiException(
        body['message'] ?? 'API request failed',
        statusCode: response.statusCode,
      );
    }
  }

  Exception _handleError(dynamic error) {
    if (error is ApiException) return error;
    return NetworkException('Network error occurred: $error');
  }
}
