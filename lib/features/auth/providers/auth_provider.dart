import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_models.dart';
import '../repositories/auth_repository.dart';

// ── Storage keys ───────────────────────────────────────────────────
const _accessTokenKey = 'access_token';
const _refreshTokenKey = 'refresh_token';

// ── Providers ──────────────────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>(
  (_) => AuthRepository(),
);

final _storageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

// ── Auth state ─────────────────────────────────────────────────────
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserProfile? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserProfile? user,
    bool? isLoading,
    String? error,
  }) => AuthState(
    status: status ?? this.status,
    user: user ?? this.user,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

// ── Auth notifier ─────────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final FlutterSecureStorage _storage;

  AuthNotifier(this._repo, this._storage) : super(const AuthState()) {
    _checkAuth();
  }

  // Check if user is already logged in on app start
  Future<void> _checkAuth() async {
    final token = await _storage.read(key: _accessTokenKey);
    if (token != null) {
      try {
        final user = await _repo.getProfile();
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } catch (_) {
        await _clearTokens();
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  // ── Register ───────────────────────────────────────────────────
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.register(
        RegisterRequest(
          email: email,
          password: password,
          displayName: displayName,
        ),
      );
      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    }
  }

  // ── Login ──────────────────────────────────────────────────────
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tokens = await _repo.login(
        LoginRequest(email: email, password: password),
      );

      // Save tokens securely
      await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
      await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken);

      // Fetch profile
      final user = await _repo.getProfile();

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
      );
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    }
  }

  // ── Forgot password ────────────────────────────────────────────
  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.forgotPassword(email);
      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    }
  }

  // ── Logout ─────────────────────────────────────────────────────
  Future<void> logout() async {
    await _clearTokens();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(_storageProvider),
  );
});
