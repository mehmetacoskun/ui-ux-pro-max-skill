import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/auth_response.dart';
import '../models/user.dart';
import '../utils/api_config.dart';
import 'token_manager.dart';
import 'api_client.dart';

class AuthService {
  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? ApiClient();

  dynamic _safeDecode(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (e) {
      throw AuthException('Invalid server response (Format Error)');
    }
  }

  Future<void> requestOtp(String email) async {
    final url = ApiConfig.baseUrl + ApiConfig.requestOtp;

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      final errorBody = _safeDecode(response);
      throw AuthException(
          errorBody['error'] ?? errorBody['detail'] ?? 'OTP request failed');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Network error or server unavailable');
    }
  }

  Future<AuthResponse> verifyOtp(String email, String otpCode) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.verifyOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': otpCode}),
      );

      final data = _safeDecode(response);

      if (response.statusCode != 200) {
        throw AuthException(
            data['error'] ?? data['detail'] ?? 'OTP verification failed');
      }

      final authResponse = AuthResponse.fromJson(data as Map<String, dynamic>);
      await TokenManager.saveTokens(authResponse);
      return authResponse;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Failed to verify OTP: $e');
    }
  }

  Future<AuthResponse> refreshToken() async {
    final refreshToken = await TokenManager.getRefreshToken();
    if (refreshToken == null) {
      throw AuthException('Session expired. Please login again.');
    }

    try {
      final response = await _client.post(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.refreshToken),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode != 200) {
        await TokenManager.clearTokens();
        throw AuthException('Session expired');
      }

      final data = _safeDecode(response);
      final authResponse = AuthResponse.fromJson(data as Map<String, dynamic>);

      await TokenManager.updateTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );
      await TokenManager.updateUser(authResponse.user.toJson());
      return authResponse;
    } catch (e) {
      if (e is AuthException) {
        // Zaten clearTokens çagrildi veya sessizce geçilebilir
        rethrow;
      }
      // Ag hatasi vs. ise tokenleri silme ki offline devam edebilelim
      throw AuthException('Failed to refresh session: $e');
    }
  }

  Future<User> getUser() async {
    final response = await _client.get(
      Uri.parse(ApiConfig.baseUrl + ApiConfig.userMe),
    );

    if (response.statusCode != 200) {
      throw AuthException('Failed to fetch user profile');
    }

    return User.fromJson(_safeDecode(response) as Map<String, dynamic>);
  }

  Future<User> updateUser({String? adiSoyadi, String? telefonNumarasi}) async {
    final body = <String, dynamic>{};
    if (adiSoyadi != null) body['full_name'] = adiSoyadi;
    if (telefonNumarasi != null) body['phone'] = telefonNumarasi;

    final response = await _client.put(
      Uri.parse(ApiConfig.baseUrl + ApiConfig.userMe),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw AuthException('Failed to update user profile');
    }

    final user = User.fromJson(_safeDecode(response) as Map<String, dynamic>);
    await TokenManager.updateUser(user.toJson());
    return user;
  }

  Future<User> uploadAvatar(List<int> fileBytes, String filename) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConfig.baseUrl + ApiConfig.userAvatar),
    );

    String mimeType = 'image/jpeg';
    if (filename.toLowerCase().endsWith('.png'))
      mimeType = 'image/png';
    else if (filename.toLowerCase().endsWith('.gif'))
      mimeType = 'image/gif';
    else if (filename.toLowerCase().endsWith('.webp')) mimeType = 'image/webp';

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: filename,
        contentType: MediaType.parse(mimeType),
      ),
    );

    try {
      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        final errorData = _safeDecode(response);
        throw AuthException(errorData['error'] ??
            errorData['detail'] ??
            'Failed to upload avatar');
      }

      final user = User.fromJson(_safeDecode(response) as Map<String, dynamic>);
      await TokenManager.updateUser(user.toJson());
      return user;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Avatar upload failed: $e');
    }
  }

  Future<void> logout() async {
    await TokenManager.clearTokens();
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
