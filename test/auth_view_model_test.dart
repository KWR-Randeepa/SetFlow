import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:setflow/features/auth/models/app_user.dart';
import 'package:setflow/features/auth/repositories/auth_repository.dart';
import 'package:setflow/features/auth/viewmodels/auth_view_model.dart';

class FakeAuthRepository implements AuthRepository {
  static const sample = AppUser(id: 'account-a', fullName: 'Alex', email: 'alex@example.com');
  AppUser? saved;
  bool failRestore = false;
  bool failLogout = false;
  int loginCalls = 0;
  int registerCalls = 0;
  Completer<void>? loginDelay;
  @override
  Future<void> register({required String fullName, required String email,
      required String password}) async { registerCalls++; }
  @override
  Future<AppUser> login({required String email, required String password}) async {
    loginCalls++;
    if (loginDelay != null) await loginDelay!.future;
    if (password != 'secret123') throw const AuthFailure('Email or password is incorrect.');
    return saved = sample;
  }
  @override
  Future<AppUser?> restoreSession() async {
    if (failRestore) throw Exception('Storage unavailable');
    return saved;
  }
  @override
  Future<void> logout() async {
    if (failLogout) throw Exception('Storage unavailable');
    saved = null;
  }
}

void main() {
  late FakeAuthRepository repository;
  late AuthViewModel vm;
  setUp(() { repository = FakeAuthRepository(); vm = AuthViewModel(repository); });
  tearDown(() => vm.dispose());

  test('registration rejects mismatch before calling repository', () async {
    expect(await vm.register(fullName: 'Alex', email: 'alex@example.com',
      password: 'secret123', confirmPassword: 'different'), isFalse);
    expect(repository.registerCalls, 0);
    expect(vm.error, 'Passwords do not match.');
  });

  test('incorrect login leaves account unset', () async {
    expect(await vm.login(email: 'alex@example.com', password: 'wrong123'), isFalse);
    expect(vm.user, isNull);
    expect(vm.busy, isFalse);
  });

  test('concurrent login submissions only call repository once', () async {
    repository.loginDelay = Completer<void>();
    final first = vm.login(email: 'alex@example.com', password: 'secret123');
    expect(vm.busy, isTrue);
    expect(await vm.login(email: 'alex@example.com', password: 'secret123'), isFalse);
    repository.loginDelay!.complete();
    expect(await first, isTrue);
    expect(repository.loginCalls, 1);
  });

  test('restore failure keeps gate closed; retry restores account', () async {
    repository.failRestore = true;
    await vm.restoreSession();
    expect(vm.initializing, isTrue);
    expect(vm.error, isNotNull);
    repository.failRestore = false;
    repository.saved = FakeAuthRepository.sample;
    await vm.restoreSession();
    expect(vm.initializing, isFalse);
    expect(vm.user?.id, 'account-a');
  });

  test('logout only clears UI account after persistent deletion succeeds', () async {
    await vm.login(email: 'alex@example.com', password: 'secret123');
    repository.failLogout = true;
    expect(await vm.logout(), isFalse);
    expect(vm.user, isNotNull);
    repository.failLogout = false;
    expect(await vm.logout(), isTrue);
    expect(vm.user, isNull);
    expect(repository.saved, isNull);
  });
}