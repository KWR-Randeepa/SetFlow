import 'package:flutter/foundation.dart';
import '../../../core/validators.dart';
import '../models/app_user.dart';
import '../repositories/auth_repository.dart';

// One shared authentication feature ViewModel coordinates register/login/logout.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repository);
  final AuthRepository _repository;
  AppUser? _user;
  AppUser? get user => _user;
  bool _busy = false;
  bool get busy => _busy;
  bool _initializing = true;
  bool get initializing => _initializing;
  String? _error;
  String? get error => _error;
  bool _disposed = false;

  void _emit() { if (!_disposed) notifyListeners(); }
  void clearError() { _error = null; _emit(); }

  Future<void> restoreSession() async {
    if (_busy) return;
    _busy = true;
    _initializing = true;
    _error = null;
    _emit();
    try {
      _user = await _repository.restoreSession();
      _initializing = false;
    } catch (_) {
      _error = 'Could not open your local session. Please retry.';
      // Keep the gate closed until storage has been read successfully.
    } finally {
      _busy = false;
      _emit();
    }
  }

  Future<bool> register({required String fullName, required String email,
      required String password, required String confirmPassword}) async {
    if (_busy) return false;
    final validation = Validators.name(fullName) ?? Validators.email(email) ??
        Validators.password(password) ??
        Validators.confirmPassword(confirmPassword, password);
    if (validation != null) {
      _error = validation;
      _emit();
      return false;
    }
    return _run(() => _repository.register(
      fullName: fullName, email: email, password: password));
  }

  Future<bool> login({required String email, required String password}) =>
      _run(() async {
        _user = await _repository.login(email: email, password: password);
      });

  Future<bool> logout() => _run(() async {
    await _repository.logout();
    _user = null; // Only clear after persistent session deletion succeeds.
  });

  Future<bool> _run(Future<void> Function() action) async {
    if (_busy) return false;
    _busy = true;
    _error = null;
    _emit();
    try {
      await action();
      return true;
    } on AuthFailure catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Could not access local storage. Please try again.';
      return false;
    } finally {
      _busy = false;
      _emit();
    }
  }

  @override
  void dispose() { _disposed = true; super.dispose(); }
}