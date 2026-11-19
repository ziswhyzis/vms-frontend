import '../core/api_client.dart';
import '../core/api_exception.dart';
import '../models/user.dart';
import 'session_store.dart';

class AuthService {
  AuthService({required ApiClient apiClient, required SessionStore sessionStore})
      : _api = apiClient,
        _store = sessionStore;

  final ApiClient _api;
  final SessionStore _store;

  ApiClient get apiClient => _api;

  /// Attempts to restore a previous session. Returns `null` when there is no
  /// session or the token is no longer valid.
  Future<User?> restoreSession() async {
    final stored = await _store.read();
    if (stored == null) {
      return null;
    }
    _api.setToken(stored.token);
    try {
      final payload = await _api.get('/auth/me');
      if (payload is Map<String, dynamic>) {
        final user = User.fromJson(payload);
        await _store.save(token: stored.token, user: user);
        return user;
      }
      return stored.user;
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        await logout();
        return null;
      }
      // Network problems should not silently destroy a remembered session.
      return stored.user;
    } catch (_) {
      // Unexpected failure (bad payload, storage error): keep the operator
      // signed in optimistically; the next 401 signs them out cleanly.
      return stored.user;
    }
  }

  Future<User> login(String username, String password) async {
    final payload = await _api.post('/auth/login', {
      'username': username.trim(),
      'password': password,
    });
    if (payload is! Map<String, dynamic>) {
      throw const ApiException(500, 'Unexpected response from the sign-in service.');
    }
    final token = payload['token'];
    final rawUser = payload['user'];
    if (token is! String || token.isEmpty || rawUser is! Map<String, dynamic>) {
      throw const ApiException(500, 'The sign-in response did not include a token.');
    }
    final user = User.fromJson(rawUser);
    _api.setToken(token);
    await _store.save(token: token, user: user);
    return user;
  }

  Future<void> logout() async {
    _api.setToken(null);
    await _store.clear();
  }
}
