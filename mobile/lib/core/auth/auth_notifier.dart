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
  final String? fullName;
  final String? phoneNumber;
  final String? photoUrl;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.userId,
    this.role,
    this.isNewUser = false,
    this.fullName,
    this.phoneNumber,
    this.photoUrl,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? role,
    bool? isNewUser,
    String? fullName,
    String? phoneNumber,
    String? photoUrl,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      isNewUser: isNewUser ?? this.isNewUser,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
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
    final fullName = await SecureStorage.getFullName();
    final phoneNumber = await SecureStorage.getPhone();
    final photoUrl = await SecureStorage.getPhotoUrl();
    return AuthState(
      status: AuthStatus.authenticated,
      userId: userId,
      role: role,
      fullName: fullName,
      phoneNumber: phoneNumber,
      photoUrl: photoUrl,
    );
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
          final fullName = resp.data['full_name'] as String?;
          final phoneNumber = resp.data['phone_number'] as String?;
          await SecureStorage.saveJwt(jwt);
          await SecureStorage.saveUser(userId: userId, role: role);
          if (fullName != null || phoneNumber != null) {
            await SecureStorage.saveProfile(
              fullName: fullName ?? '',
              phone: phoneNumber ?? '',
            );
          }
          state = AsyncData(AuthState(
            status: AuthStatus.authenticated,
            userId: userId,
            role: role,
            isNewUser: isNew,
            fullName: fullName,
            phoneNumber: phoneNumber,
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

  Future<void> updateProfile({String? fullName, String? phoneNumber, String? photoUrl}) async {
    final data = <String, dynamic>{};
    if (fullName != null) data['full_name'] = fullName;
    if (phoneNumber != null) data['phone_number'] = phoneNumber;
    if (photoUrl != null) data['photo_url'] = photoUrl;
    await _dio.put('/update-profile', data: data);
    await SecureStorage.saveProfile(
      fullName: fullName ?? state.value?.fullName ?? '',
      phone: phoneNumber ?? state.value?.phoneNumber ?? '',
    );
    if (photoUrl != null) await SecureStorage.savePhotoUrl(photoUrl);
    state = AsyncData(state.value!.copyWith(
      fullName: fullName,
      phoneNumber: phoneNumber,
      photoUrl: photoUrl,
    ));
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

// Dio provider — overridden in main
final dioProvider = Provider<Dio>((ref) => throw UnimplementedError());
