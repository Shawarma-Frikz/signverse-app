import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/auth_models.dart';

class AuthException implements Exception {
  final String message;
  final int? statusCode;
  const AuthException(this.message, {this.statusCode});
}

class AuthRepository {
  final Dio _dio = ApiClient.instance;

  // ── Register ───────────────────────────────────────────────────
  Future<void> register(RegisterRequest request) async {
    try {
      await _dio.post(ApiConstants.register, data: request.toJson());
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Login ──────────────────────────────────────────────────────
  Future<AuthTokens> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );
      return AuthTokens.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Forgot password ────────────────────────────────────────────
  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post(ApiConstants.forgotPassword, data: {'email': email});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Get profile ────────────────────────────────────────────────
  Future<UserProfile> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.me);
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Resend verification ────────────────────────────────────────
  Future<void> resendVerification(String email) async {
    try {
      await _dio.post(ApiConstants.resendVerification, data: {'email': email});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Error handler ──────────────────────────────────────────────
  AuthException _handleError(DioException e) {
    final statusCode = e.response?.statusCode;
    final detail = e.response?.data?['detail'];

    if (detail is String) {
      return AuthException(detail, statusCode: statusCode);
    }

    switch (statusCode) {
      case 400:
        return const AuthException(
          'Invalid request. Please check your details.',
        );
      case 401:
        return const AuthException('Invalid email or password.');
      case 403:
        return const AuthException(
          'Please verify your email before logging in.',
        );
      case 422:
        return const AuthException('Please fill all fields correctly.');
      case 429:
        return const AuthException('Too many attempts. Please wait a minute.');
      case 500:
        return const AuthException('Server error. Please try again later.');
      default:
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError) {
          return const AuthException('No connection. Check your internet.');
        }
        return const AuthException('Something went wrong. Please try again.');
    }
  }
}
