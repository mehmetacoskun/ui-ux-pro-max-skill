import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/token_manager.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isInitializing = false;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  User? _user;
  String? _error;
  String? _currentEmail;

  bool get isInitializing => _isInitializing;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  User? get user => _user;
  String? get error => _error;
  String? get currentEmail => _currentEmail;

  Future<void> checkAuth() async {
    _isInitializing = true;
    _error = null;
    notifyListeners();

    try {
      final hasTokens = await TokenManager.hasTokens();
      if (hasTokens) {
        try {
          // Refresh token varsa login olmayi dene
          await _authService.refreshToken();
          final userJson = await TokenManager.getUser();
          if (userJson != null) {
            _user = User.fromJson(userJson);
            _isAuthenticated = true;
          } else {
            _isAuthenticated = false;
          }
        } catch (e) {
          // Token yenileme basarisiz olursa (örn. süresi dolmussa)
          // AuthService.refreshToken zaten TokenManager'i temizledi.
          // Internet yoksa lokal verilerle devam et, aksi halde login'e gönder.
          if (e.toString().contains('Network error') ||
              e.toString().contains('unavailable')) {
            final userJson = await TokenManager.getUser();
            if (userJson != null) {
              _user = User.fromJson(userJson);
              _isAuthenticated = true;
            } else {
              _isAuthenticated = false;
            }
          } else {
            // Auth hatasi ise login ekranina yönlendirmek için authenticated'i false yap
            _isAuthenticated = false;
            _user = null;
          }
        }
      } else {
        // Refresh token yoksa login ekranina yönlendir
        _isAuthenticated = false;
        _user = null;
      }
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<bool> requestOtp(String email) async {
    _isLoading = true;
    _error = null;
    _currentEmail = email;
    notifyListeners();
    try {
      await _authService.requestOtp(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String otpCode) async {
    if (_currentEmail == null) {
      _error = 'Email not found';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authResponse =
          await _authService.verifyOtp(_currentEmail!, otpCode);
      _user = authResponse.user;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshUser() async {
    try {
      _user = await _authService.getUser();
      notifyListeners();
    } catch (e) {
      if (e.toString().contains('Token refresh failed')) {
        await logout(onLogout: () {});
      }
    }
  }

  Future<void> logout({VoidCallback? onLogout}) async {
    await _authService.logout();
    await TokenManager.clearTodoCache();
    _user = null;
    _isAuthenticated = false;
    _currentEmail = null;
    onLogout?.call();
    notifyListeners();
  }

  Future<bool> updateUser({String? adiSoyadi, String? telefonNumarasi}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final updatedUser = await _authService.updateUser(
        adiSoyadi: adiSoyadi,
        telefonNumarasi: telefonNumarasi,
      );
      _user = updatedUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadAvatar(List<int> fileBytes, String filename) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final updatedUser = await _authService.uploadAvatar(fileBytes, filename);
      _user = updatedUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
