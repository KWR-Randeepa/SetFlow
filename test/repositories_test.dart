import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:setflow/core/validators.dart';
import 'package:setflow/data/local_database.dart';
import 'package:setflow/features/auth/repositories/auth_repository.dart';
import 'package:setflow/features/auth/repositories/local_auth_repository.dart';
import 'package:setflow/features/auth/services/password_service.dart';
import 'package:setflow/features/auth/services/session_store.dart';
import 'package:setflow/features/workouts/repositories/workout_repository.dart';

class MemorySessionStore implements SessionStore {
  String? id;
  @override
  Future<String?> readUserId() async => id;
  @override
  Future<void> writeUserId(String value) async { id = value; }
  @override
  Future<void> clear() async { id = null; }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Database db;
  late LocalDatabase database;
  late MemorySessionStore session;
  late LocalAuthRepository auth;
  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
      options: OpenDatabaseOptions(version: 1,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: LocalDatabase.createSchema));
    database = LocalDatabase(db);
    session = MemorySessionStore();
    auth = LocalAuthRepository(database, PasswordService(), session);
  });
  tearDown(() => db.close());

  test('hashes password, normalizes email, restores and deletes session', () async {
    await auth.register(fullName: ' Alex ', email: ' Alex@Example.com ', password: 'secret123');
    final row = (await db.query('users')).single;
    expect(row['password_hash'], isNot('secret123'));
    expect((row['password_hash'] as String).startsWith(r'$2'), isTrue);
    expect(row['full_name'], 'Alex');
    expect(row['email'], 'alex@example.com');
    expect(session.id, isNull); // Registration deliberately returns to login.
    final user = await auth.login(email: 'ALEX@example.com', password: 'secret123');
    expect((await auth.restoreSession())?.id, user.id);
    await auth.logout();
    expect(await auth.restoreSession(), isNull);
  });

  test('duplicate case-insensitive email and incorrect password are rejected', () async {
    await auth.register(fullName: 'Alex', email: 'alex@example.com', password: 'secret123');
    await expectLater(auth.register(fullName: 'Other', email: 'ALEX@example.com',
      password: 'secret456'), throwsA(isA<AuthFailure>()));
    await expectLater(auth.login(email: 'alex@example.com', password: 'wrong123'),
      throwsA(isA<AuthFailure>()));
    expect(session.id, isNull);
  });

  test('stale session is removed if user no longer exists', () async {
    session.id = 'removed-user';
    expect(await auth.restoreSession(), isNull);
    expect(session.id, isNull);
  });

  test('ST-13: account B cannot list or modify account A exercises', () async {
    for (final id in ['a', 'b']) {
      await db.insert('users', {'id': id, 'full_name': id,
        'email': '$id@example.com', 'password_hash': 'unused-test-hash'});
    }
    final accountA = WorkoutRepository(database, 'a');
    final accountB = WorkoutRepository(database, 'b');
    await accountA.add('Push-ups');
    final exercise = (await accountA.list()).single;
    expect(await accountB.list(), isEmpty);
    await expectLater(accountB.setDone(exercise.id, true), throwsStateError);
    expect((await accountA.list()).single.done, isFalse);
    await accountA.setDone(exercise.id, true);
    expect((await accountA.list()).single.done, isTrue);
  });

  test('password rules enforce bcrypt byte boundary, including Unicode', () {
    expect(Validators.password('a' * 72), isNull);
    expect(Validators.password('a' * 73), isNotNull);
    expect(Validators.password('🙂' * 19), isNotNull);
    expect(Validators.password('      '), isNotNull);
    expect(Validators.password('12345'), isNotNull);
  });
}