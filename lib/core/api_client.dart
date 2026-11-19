import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';
import 'config.dart';

/// Thin JSON client for the Stark Group VMS REST API.
///
/// - Injects the JWT bearer token on every request.
/// - Converts non-2xx responses into [ApiException]s, preserving the
///   backend `message` and `fieldErrors` payloads.
/// - Fires [onUnauthorized] when an authenticated request is rejected,
///   so the UI can return the operator to the sign-in screen.
class ApiClient {
  ApiClient({http.Client? httpClient, String? baseUrl})
      : _http = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final http.Client _http;
  final String _baseUrl;
  String? _token;

  void Function()? onUnauthorized;

  static const Duration _timeout = Duration(seconds: 20);

  String get baseUrl => _baseUrl;
  String? get token => _token;

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Uri _uri(String path, [Map<String, Object?>? query]) {
    final uri = Uri.parse('$_baseUrl$path');
    if (query == null || query.isEmpty) {
      return uri;
    }
    return uri.replace(
      queryParameters: {
        for (final entry in query.entries) entry.key: '${entry.value}',
      },
    );
  }

  Future<dynamic> get(String path, {Map<String, Object?>? query}) =>
      _send(() => _http.get(_uri(path, query), headers: _headers));

  Future<dynamic> post(String path, Object body) =>
      _send(() => _http.post(_uri(path), headers: _headers, body: jsonEncode(body)));

  Future<dynamic> put(String path, Object body) =>
      _send(() => _http.put(_uri(path), headers: _headers, body: jsonEncode(body)));

  Future<dynamic> delete(String path) =>
      _send(() => _http.delete(_uri(path), headers: _headers));

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    http.Response response;
    try {
      response = await request().timeout(_timeout);
    } on TimeoutException {
      throw const ApiException(0, 'The server took too long to respond. Please try again.');
    } catch (error) {
      if (error is ApiException) {
        rethrow;
      }
      throw const ApiException(0, 'Could not reach the server. Is the backend running?');
    }

    final decoded = _decode(response.body);

    if (response.statusCode == 401) {
      if (_token != null) {
        onUnauthorized?.call();
      }
      throw ApiException(
        401,
        _messageFrom(decoded) ?? 'Your session has expired. Please sign in again.',
      );
    }

    if (response.statusCode >= 400) {
      throw ApiException(
        response.statusCode,
        _messageFrom(decoded) ?? 'Request failed with status ${response.statusCode}.',
        fieldErrors: _fieldErrorsFrom(decoded),
      );
    }

    return decoded;
  }

  dynamic _decode(String body) {
    if (body.isEmpty) {
      return null;
    }
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  String? _messageFrom(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final message = decoded['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return null;
  }

  Map<String, String> _fieldErrorsFrom(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final errors = decoded['fieldErrors'];
      if (errors is Map) {
        return errors.map((key, value) => MapEntry('$key', '$value'));
      }
    }
    return const {};
  }
}
