import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/app_logger.dart';

abstract final class StorageKeys {
  static const String token = 'auth_token';
  static const String user = 'auth_user';
  static const String rememberMe = 'remember_me';
}

class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) async {
    await _storage.write(key: StorageKeys.token, value: token);
    appLogger.d('Token saved.');
  }

  Future<String?> getToken() => _storage.read(key: StorageKeys.token);

  Future<void> removeToken() => _storage.delete(key: StorageKeys.token);

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.write(key: StorageKeys.user, value: jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final raw = await _storage.read(key: StorageKeys.user);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> removeUser() => _storage.delete(key: StorageKeys.user);

  Future<void> saveRememberMe({required bool value}) =>
      _storage.write(key: StorageKeys.rememberMe, value: value.toString());

  Future<bool> getRememberMe() async {
    final val = await _storage.read(key: StorageKeys.rememberMe);
    return val == 'true';
  }

  Future<void> clearAll() => _storage.deleteAll();
}
