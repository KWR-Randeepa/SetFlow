import 'package:flutter/foundation.dart';
import '../models/exercise.dart';
import '../repositories/workout\\\_repository.dart';

class WorkoutViewModel extends ChangeNotifier {
  WorkoutViewModel(this.\\\_repository);
  final WorkoutRepository \\\_repository;
  List<Exercise> \\\_items = \\\[];
  List<Exercise> get items => List.unmodifiable(\\\_items);
  bool busy = false;
  String? error;
  bool \\\_disposed = false;
  void \\\_emit() { if (!\\\_disposed) notifyListeners(); }

  Future<bool> load() => \\\_run(() async {});
  Future<bool> add(String title) => \\\_run(() => \\\_repository.add(title));
  Future<bool> toggle(Exercise item) =>
      \\\_run(() => \\\_repository.setDone(item.id, !item.done));

  Future<bool> \\\_run(Future<void> Function() change) async {
    if (busy) return false;
    busy = true;
    error = null;
    \\\_emit();
    try {
      await change();
      final result = await \\\_repository.list();
      if (!\\\_disposed) \\\_items = result;
      return true;
    } catch (\\\_) {
      error = 'Could not update your routine. Please retry.';
      return false;
    } finally {
      busy = false;
      \\\_emit();
    }
  }

  @override
  void dispose() { \\\_disposed = true; \\\_items = \\\[]; super.dispose(); }
}
