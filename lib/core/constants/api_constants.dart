class ApiConstants {
  static const String baseUrl =
      'https://signverse-api-production.up.railway.app/api/v1';

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendVerification = '/auth/resend-verification';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String me = '/auth/me';
  static const String refresh = '/auth/refresh';

  // Prediction endpoints
  static const String predictAlphabet = '/predict/alphabet';
  static const String feedback = '/predict/feedback';
}
