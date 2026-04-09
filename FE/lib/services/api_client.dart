import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'token_manager.dart';
import '../models/auth_response.dart';
import '../utils/api_config.dart';

class ApiClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  final Connectivity _connectivity = Connectivity();

  bool _isRefreshing = false;
  final List<Completer<String?>> _refreshQueue = [];

  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (!await isOnline) {
      throw NetworkException('No internet connection');
    }

    final token = await TokenManager.getAccessToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    var response = await _inner.send(request);

    if (response.statusCode == 401 &&
        !request.url.path.contains(ApiConfig.refreshToken)) {
      final newToken = await _handleUnauthorized();

      if (newToken != null) {
        final newRequest = _copyRequest(request, newToken);
        return _inner.send(newRequest);
      }
    }

    return response;
  }

  Future<String?> _handleUnauthorized() async {
    if (_isRefreshing) {
      final completer = Completer<String?>();
      _refreshQueue.add(completer);
      return completer.future;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await TokenManager.getRefreshToken();
      if (refreshToken == null) {
        _completeAllRefreshQueue(null);
        return null;
      }

      final response = await _inner.post(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.refreshToken),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);

        await TokenManager.updateTokens(
            authResponse.accessToken, authResponse.refreshToken);
        await TokenManager.updateUser(authResponse.user.toJson());

        _completeAllRefreshQueue(authResponse.accessToken);
        return authResponse.accessToken;
      } else {
        await TokenManager.clearTokens();
        _completeAllRefreshQueue(null);
        return null;
      }
    } catch (e) {
      await TokenManager.clearTokens();
      _completeAllRefreshQueue(null);
      return null;
    } finally {
      _isRefreshing = false;
    }
  }

  void _completeAllRefreshQueue(String? token) {
    for (final completer in _refreshQueue) {
      completer.complete(token);
    }
    _refreshQueue.clear();
  }

  http.BaseRequest _copyRequest(http.BaseRequest request, String newToken) {
    http.BaseRequest newRequest;
    if (request is http.MultipartRequest) {
      newRequest = http.MultipartRequest(request.method, request.url)
        ..fields.addAll(request.fields)
        ..files.addAll(request.files);
    } else if (request is http.Request) {
      newRequest = http.Request(request.method, request.url)
        ..bodyBytes = request.bodyBytes;
    } else {
      newRequest = request;
    }

    newRequest.headers.addAll(request.headers);
    newRequest.headers['Authorization'] = 'Bearer $newToken';
    return newRequest;
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => message;
}
