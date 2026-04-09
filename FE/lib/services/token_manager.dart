import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';

typedef JsonMap = Map<String, dynamic>;

class TokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user';
  static const String _todosCacheKey = 'todos_cache';
  static const String _todosCacheTimeKey = 'todos_cache_time';

  static FlutterSecureStorage? _secureStorage;

  static Future<FlutterSecureStorage> get _storage async {
    _secureStorage ??= const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
    return _secureStorage!;
  }

  static Future<void> saveTokens(AuthResponse response) async {
    final storage = await _storage;
    await storage.write(key: _accessTokenKey, value: response.accessToken);
    await storage.write(key: _refreshTokenKey, value: response.refreshToken);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(response.user.toJson()));
  }

  static Future<String?> getAccessToken() async {
    final storage = await _storage;
    return storage.read(key: _accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final storage = await _storage;
    return storage.read(key: _refreshTokenKey);
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      return jsonDecode(userStr) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<void> updateTokens(
      String accessToken, String refreshToken) async {
    final storage = await _storage;
    await storage.write(key: _accessTokenKey, value: accessToken);
    await storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  static Future<void> updateUser(Map<String, dynamic> userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userJson));
  }

  static Future<void> clearTokens() async {
    final storage = await _storage;
    await storage.delete(key: _accessTokenKey);
    await storage.delete(key: _refreshTokenKey);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  static Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }

  static Future<void> cacheTodos(List<Map<String, dynamic>> todos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_todosCacheKey, jsonEncode(todos));
    await prefs.setInt(
        _todosCacheTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<List<JsonMap>?> getCachedTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedTime = prefs.getInt(_todosCacheTimeKey);

    if (cachedTime == null) return null;

    final cacheAge = DateTime.now().millisecondsSinceEpoch - cachedTime;
    if (cacheAge > 30 * 60 * 1000) return null;

    final todosStr = prefs.getString(_todosCacheKey);
    if (todosStr != null) {
      final decoded = jsonDecode(todosStr) as List<dynamic>;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return null;
  }

  static Future<void> clearTodoCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_todosCacheKey);
    await prefs.remove(_todosCacheTimeKey);
  }
}
