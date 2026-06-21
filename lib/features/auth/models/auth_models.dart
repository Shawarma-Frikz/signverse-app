class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  final String email;
  final String password;
  final String displayName;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.displayName,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'display_name': displayName,
  };
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({required this.accessToken, required this.refreshToken});

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
    accessToken: json['access_token'] as String,
    refreshToken: json['refresh_token'] as String,
  );
}

class UserProfile {
  final int id;
  final String email;
  final String? displayName;
  final String? bio;
  final String? avatarUrl;
  final String preferredLanguage;
  final bool isVerified;
  final String createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.bio,
    this.avatarUrl,
    required this.preferredLanguage,
    required this.isVerified,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as int,
    email: json['email'] as String,
    displayName: json['display_name'] as String?,
    bio: json['bio'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    preferredLanguage: json['preferred_language'] as String,
    isVerified: json['is_verified'] as bool,
    createdAt: json['created_at'] as String,
  );
}
