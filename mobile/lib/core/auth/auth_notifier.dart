import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'secure_storage.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? role;
  final bool isNewUser;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.userId,
    this.role,
    this.isNewUser = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? role,
    bool? isNewUser,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  late Dio _dio;

  @override
  Future<AuthState> build() async {
    _dio = ref.read(dioProvider);
    return _checkSession();
  }

  Future<AuthState> _checkSession() async {
    final jwt = await SecureStorage.getJwt();
    if (jwt == null) return const AuthState(status: AuthStatus.unauthenticated);
    final userId = await SecureStorage.getUserId();
    final role = await SecureStorage.getRole();
    return AuthState(status: AuthStatus.authenticated, userId: userId, role: role);
  }

  /// Step 1: call init, get Telegram deep link
  Future<({String token, String telegramUrl})> initTelegramAuth(String deviceId) async {
    final resp = await _dio.post('/auth-telegram-init', data: {'device_id': deviceId});
    return (
      token: resp.data['token'] as String,
      telegramUrl: resp.data['telegram_url'] as String,
    );
  }

  /// Step 2: poll verify endpoint until confirmed
  Future<bool> pollVerify(String token) async {
    const maxAttempts = 150; // 5 minutes @ 2s
    int attempts = 0;
    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 2));
      try {
        final resp = await _dio.get('/auth-telegram-verify', queryParameters: {'token': token});
        if (resp.statusCode == 200) {
          final jwt = resp.data['jwt'] as String;
          final userId = resp.data['user_id'] as String;
          final role = resp.data['role'] as String? ?? 'citizen';
          final isNew = resp.data['is_new_user'] as bool? ?? false;
          await SecureStorage.saveJwt(jwt);
          await SecureStorage.saveUser(userId: userId, role: role);
          state = AsyncData(AuthState(
            status: AuthStatus.authenticated,
            userId: userId,
            role: role,
            isNewUser: isNew,
          ));
          return true;
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          // Token expired
          return false;
        }
        // 202 pending — keep polling
      }
      attempts++;
    }
    return false;
  }

  Future<void> signOut() async {
    await SecureStorage.clear();
    state = const AsyncData(AuthState(status: AuthStatus.unauthenticated));
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

// Dio provider — overridden in main
final dioProvider = Provider<Dio>((ref) => throw UnimplementedError());
