import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SessionStore {
  Future<String?> readUserId();
  Future<void> writeUserId(String id);
  Future<void> clear();
}

class SecureSessionStore implements SessionStore {
  SecureSessionStore(this._storage);
  final FlutterSecureStorage _storage;
  static const _key = 'routine.active_user.v1';

  @override
  Future<String?> readUserId() => _storage.read(key: _key);
  @override
  Future<void> writeUserId(String id) => _storage.write(key: _key, value: id);
  @override
  Future<void> clear() => _storage.delete(key: _key);
}