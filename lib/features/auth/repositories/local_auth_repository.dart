import 'package:sqflite/sqflite.dart';
import '../../../core/new_id.dart';
import '../../../core/validators.dart';
import '../../../data/local_database.dart';
import '../models/app_user.dart';
import '../services/password_service.dart';
import '../services/session_store.dart';
import 'auth_repository.dart';

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._database, this._passwords, this._session);
  final LocalDatabase _database;
  final PasswordService _passwords;
  final SessionStore _session;

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final error =
        Validators.name(fullName) ??
        Validators.email(email) ??
        Validators.password(password);
    if (error != null) throw AuthFailure(error);
    final normalizedEmail = email.trim().toLowerCase();
    if ((await _database.db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    )).isNotEmpty) {
      throw const AuthFailure('An account with this email already exists.');
    }
    final hash = await _passwords.hash(password);
    try {
      await _database.db.insert('users', {
        'id': newId(),
        'full_name': fullName.trim(),
        'email': normalizedEmail,
        'password_hash': hash,
      });
    } on DatabaseException catch (e) {
      // The database constraint also handles concurrent duplicate registration.
      if (e.isUniqueConstraintError()) {
        throw const AuthFailure('An account with this email already exists.');
      }
      rethrow;
    }
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    const invalid = AuthFailure('Email or password is incorrect.');
    if (Validators.email(email) != null ||
        Validators.password(password) != null) {
      throw invalid;
    }
    final rows = await _database.db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) throw invalid;
    final row = rows.single;
    if (!await _passwords.verify(password, row['password_hash'] as String)) {
      throw invalid;
    }
    final user = AppUser.fromMap(row);
    await _session.writeUserId(user.id);
    return user;
  }

  @override
  Future<AppUser?> restoreSession() async {
    final id = await _session.readUserId();
    if (id == null) return null;
    final rows = await _database.db.query(
      'users',
      columns: ['id', 'full_name', 'email'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      await _session.clear();
      return null;
    }
    return AppUser.fromMap(rows.single);
  }

  @override
  Future<void> logout() => _session.clear();
}
