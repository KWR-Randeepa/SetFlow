import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app.dart';
import 'core/app_theme.dart';
import 'data/local_database.dart';
import 'features/auth/repositories/local_auth_repository.dart';
import 'features/auth/services/password_service.dart';
import 'features/auth/services/session_store.dart';
import 'features/auth/viewmodels/auth_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _Bootstrap());
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap();
  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  LocalDatabase? _database;
  AuthViewModel? _auth;
  bool _failed = false;

  @override
  void initState() { super.initState(); _start(); }

  Future<void> _start() async {
    setState(() => _failed = false);
    try {
      final database = await LocalDatabase.open();
      if (!mounted) { await database.db.close(); return; }
      final auth = AuthViewModel(LocalAuthRepository(
        database, PasswordService(),
        SecureSessionStore(const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        )),
      ));
      setState(() { _database = database; _auth = auth; });
      await auth.restoreSession();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() { _auth?.dispose(); _database?.db.close(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_auth != null) return RoutineApp(auth: _auth!, database: _database!);
    return MaterialApp(debugShowCheckedModeBanner: false, theme: buildAppTheme(),
      home: Scaffold(body: Center(child: Padding(
        padding: const EdgeInsets.all(32),
        child: _failed ? Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Could not open local storage.', textAlign: TextAlign.center),
          const SizedBox(height: 20),
          FilledButton(onPressed: _start, child: const Text('Retry')),
        ]) : const CircularProgressIndicator(),
      ))),
    );
  }
}