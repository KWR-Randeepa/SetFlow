import '../../../core/new_id.dart';
import '../../../data/local_database.dart';
import '../models/exercise.dart';

// A repository instance belongs to one account for its entire lifetime.
// The UI cannot supply arbitrary owner IDs when reading/updating exercises.
class WorkoutRepository {
  WorkoutRepository(this._database, this._userId);
  final LocalDatabase _database;
  final String _userId;

  Future<List<Exercise>> list() async {
    final rows = await _database.db.query('exercises',
      where: 'user_id = ?', whereArgs: [_userId], orderBy: 'created_at DESC, id DESC');
    return rows.map(Exercise.fromMap).toList();
  }

  Future<void> add(String title) async {
    final value = title.trim();
    if (value.isEmpty || value.length > 100) {
      throw ArgumentError('Exercise must contain 1–100 characters.');
    }
    await _database.db.insert('exercises', {
      'id': newId(), 'user_id': _userId, 'title': value,
      'is_done': 0, 'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> setDone(String id, bool done) async {
    final changed = await _database.db.update('exercises', {'is_done': done ? 1 : 0},
      where: 'id = ? AND user_id = ?', whereArgs: [id, _userId]);
    if (changed != 1) throw StateError('Exercise does not belong to this account.');
  }
}