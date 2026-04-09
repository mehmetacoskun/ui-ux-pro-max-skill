import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kDebugMode) {
      return const String.fromEnvironment('API_BASE_URL',
          defaultValue: 'https://otp.joshqun.com/api');
    }
    return 'https://otp.joshqun.com/api';
  }

  static String get localUrl {
    if (kDebugMode) {
      return const String.fromEnvironment('API_LOCAL_URL',
          defaultValue: 'https://otp.joshqun.com');
    }
    return 'https://otp.joshqun.com';
  }

  static const String requestOtp = '/auth/otp';
  static const String verifyOtp = '/auth/verify';
  static const String refreshToken = '/auth/refresh';
  static const String userMe = '/auth/me';
  static const String userAvatar = '/auth/me/avatar';
  static const String todos = '/todos';

  static String todoById(int id) => '/todos/$id';

  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const Duration cacheExpiry = Duration(minutes: 30);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}
