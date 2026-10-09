import '../models/app_user.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;
}

abstract class AuthRepository {
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  });
  Future<AppUser> login({required String email, required String password});
  Future<AppUser?> restoreSession();
  Future<void> logout();
}