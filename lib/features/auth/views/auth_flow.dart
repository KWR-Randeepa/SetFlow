import 'package:flutter/material.dart';
import '../viewmodels/auth_view_model.dart';
import 'login_view.dart';
import 'register_view.dart';

class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key, required this.viewModel, this.initialRegister = false});
  final AuthViewModel viewModel;
  final bool initialRegister;

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  late bool _register = widget.initialRegister;
  bool _accountCreated = false;
  String _email = '';

  void _switch(bool register, {String? email}) {
    widget.viewModel.clearError();
    setState(() {
      _register = register;
      _accountCreated = email != null;
      _email = email ?? '';
    });
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.viewModel,
    builder: (context, _) => _register
      ? RegisterView(viewModel: widget.viewModel,
          onLogin: () => _switch(false),
          onRegistered: (email) => _switch(false, email: email))
      : LoginView(viewModel: widget.viewModel, initialEmail: _email,
          accountCreated: _accountCreated, onRegister: () => _switch(true)),
  );
}