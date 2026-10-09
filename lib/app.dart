import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'data/local_database.dart';
import 'features/auth/viewmodels/auth_view_model.dart';
import 'features/auth/views/auth_flow.dart';
import 'features/workouts/repositories/workout_repository.dart';
import 'features/workouts/viewmodels/workout_view_model.dart';
import 'features/workouts/views/workout_view.dart';

class RoutineApp extends StatelessWidget {
  const RoutineApp({super.key, required this.auth, required this.database});
  final AuthViewModel auth;
  final LocalDatabase database;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false, title: 'Routine', theme: buildAppTheme(),
    home: AuthGate(auth: auth, database: database),
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.auth, required this.database});
  final AuthViewModel auth;
  final LocalDatabase database;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: auth,
    builder: (context, _) {
      if (auth.initializing) {
        return Scaffold(body: Center(child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (auth.busy) const CircularProgressIndicator(),
            if (auth.error != null) ...[
              Text(auth.error!, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton(onPressed: auth.busy ? null : auth.restoreSession,
                child: const Text('Retry')),
            ],
          ]),
        )));
      }
      final user = auth.user;
      if (user == null) return AuthFlow(viewModel: auth);
      return _AccountScope(key: ValueKey(user.id), auth: auth, database: database,
        userId: user.id);
    },
  );
}
class _AccountScope extends StatefulWidget {
  const _AccountScope({super.key, required this.auth, required this.database,
    required this.userId});
  final AuthViewModel auth;
  final LocalDatabase database;
  final String userId;
  @override
  State<_AccountScope> createState() => _AccountScopeState();
}

class _AccountScopeState extends State<_AccountScope> {
  late final WorkoutViewModel _workouts;
  @override
  void initState() {
    super.initState();
    _workouts = WorkoutViewModel(WorkoutRepository(widget.database, widget.userId));
    _workouts.load();
  }
  @override
  void dispose() { _workouts.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => WorkoutView(auth: widget.auth, viewModel: _workouts);
}