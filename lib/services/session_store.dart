import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class StoredSession {
  const StoredSession({required this.token, required this.user});

  final String token;
  final User user;
}

/// Persists the JWT and the signed-in profile in browser local storage so a
/// page refresh keeps the operator signed in.
///
/// Reading is defensive on purpose: storage can contain values written by an
/// older build, another tab, or a developer tool. A corrupt payload must never
/// block application start-up, so anything unreadable is treated as "signed
/// out" and cleared.
class SessionStore {
  static const String _tokenKey = 'vms.token';
  static const String _userKey = 'vms.user';

  Future<void> save({required String token, required User user}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<StoredSession?> read() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final userJson = prefs.getString(_userKey);
      if (token == null || token.isEmpty || userJson == null) {
        return null;
      }
      final decoded = jsonDecode(userJson);
      if (decoded is Map<String, dynamic>) {
        return StoredSession(token: token, user: User.fromJson(decoded));
      }
    } catch (_) {
      // Unreadable or corrupt storage: fall through to a clean sign-out.
      await _clearQuietly();
    }
    return null;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<void> _clearQuietly() async {
    try {
      await clear();
    } catch (_) {
      // Storage is unavailable; nothing more can be done here.
    }
  }
}
