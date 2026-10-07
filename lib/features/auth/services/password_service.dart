import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/foundation.dart';

// Top-level isolate callbacks keep expensive bcrypt off the mobile UI thread.
String _hash(String password) =>
    BCrypt.hashpw(password, BCrypt.gensalt(logRounds: 12));
bool _verify(List<String> values) => BCrypt.checkpw(values[0], values[1]);

class PasswordService {
  Future<String> hash(String password) => compute(_hash, password);
  Future<bool> verify(String password, String hash) =>
      compute(_verify, [password, hash]);
}
