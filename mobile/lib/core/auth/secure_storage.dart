import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _jwtKey = 'citizen_jwt';
const _userIdKey = 'user_id';
const _roleKey = 'user_role';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static Future<void> saveJwt(String jwt) async {
    await _storage.write(key: _jwtKey, value: jwt);
  }

  static Future<String?> getJwt() async {
    return _storage.read(key: _jwtKey);
  }

  static Future<void> saveUser({required String userId, required String role}) async {
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _roleKey, value: role);
  }

  static Future<String?> getUserId() async {
    return _storage.read(key: _userIdKey);
  }

  static Future<String?> getRole() async {
    return _storage.read(key: _roleKey);
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }

  static Future<bool> get isLoggedIn async {
    final jwt = await getJwt();
    return jwt != null && jwt.isNotEmpty;
  }
}
