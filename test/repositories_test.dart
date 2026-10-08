import 'package:flutter\\\_test/flutter\\\_test.dart';
import 'package:sqflite\\\_common\\\_ffi/sqflite\\\_ffi.dart';
import 'package:routine\\\_mvvm/core/validators.dart';
import 'package:routine\\\_mvvm/data/local\\\_database.dart';
import 'package:routine\\\_mvvm/features/auth/repositories/auth\\\_repository.dart';
import 'package:routine\\\_mvvm/features/auth/repositories/local\\\_auth\\\_repository.dart';
import 'package:routine\\\_mvvm/features/auth/services/password\\\_service.dart';
import 'package:routine\\\_mvvm/features/auth/services/session\\\_store.dart';
import 'package:routine\\\_mvvm/features/workouts/repositories/workout\\\_repository.dart';

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
        onConfigure: (db) => db.execute('PRAGMA foreign\\\_keys = ON'),
        onCreate: LocalDatabase.createSchema));
    database = LocalDatabase(db);
    session = MemorySessionStore();
    auth = LocalAuthRepository(database, PasswordService(), session);
  });
  tearDown(() => db.close());

  test('hashes password, normalizes email, restores and deletes session', () async {
    await auth.register(fullName: ' Alex ', email: ' Alex@Example.com ', password: 'secret123');
    final row = (await db.query('users')).single;
    expect(row\\\['password\\\_hash'], isNot('secret123'));
    expect((row\\\['password\\\_hash'] as String).startsWith(r'$2'), isTrue);
    expect(row\\\['full\\\_name'], 'Alex');
    expect(row\\\['email'], 'alex@example.com');
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
    for (final id in \\\['a', 'b']) {
      await db.insert('users', {'id': id, 'full\\\_name': id,
        'email': '$id@example.com', 'password\\\_hash': 'unused-test-hash'});
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
    expect(Validators.password('a' \\\* 72), isNull);
    expect(Validators.password('a' \\\* 73), isNotNull);
    expect(Validators.password('🙂' \\\* 19), isNotNull);
    expect(Validators.password('      '), isNotNull);
    expect(Validators.password('12345'), isNotNull);
  });
}
