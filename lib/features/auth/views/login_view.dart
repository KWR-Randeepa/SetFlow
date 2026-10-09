import 'package:flutter/material.dart';
import 'package:setflow/core/app_theme.dart';
import 'package:setflow/core/validators.dart';
import 'package:setflow/features/auth/viewmodels/auth_view_model.dart';
import 'package:setflow/features/auth/views/widgets/auth_field.dart';
import 'package:setflow/features/auth/views/widgets/auth_layout.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key, required this.viewModel, required this.onRegister,
    this.initialEmail = '', this.accountCreated = false});
  final AuthViewModel viewModel;
  final VoidCallback onRegister;
  final String initialEmail;
  final bool accountCreated;
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _form = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.initialEmail);
  final _password = TextEditingController();

  Future<void> _submit() async {
    if (widget.viewModel.busy || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await widget.viewModel.login(email: _email.text, password: _password.text);
    // AuthGate observes user changes and replaces the unauthenticated tree.
  }

  @override
  void dispose() { _email.dispose(); _password.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AuthLayout(
    title: 'Welcome back.',
    subtitle: 'Your routine is waiting.\nLet’s keep moving.',
    child: AutofillGroup(child: Form(key: _form,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (widget.accountCreated) const Padding(
          padding: EdgeInsets.only(bottom: 18),
          child: Text('Account created. Log in to start your routine.',
            style: TextStyle(color: AppColors.lime)),
        ),
        AuthError(widget.viewModel.error),
        AuthField(label: 'Email Address', caption: 'Local ID', hint: 'alex@example.com',
          icon: Icons.mail_outline_rounded, controller: _email,
          validator: Validators.email, keyboardType: TextInputType.emailAddress,
          enabled: !widget.viewModel.busy,
          autofillHints: const [AutofillHints.username]),
        AuthField(label: 'Password', hint: '••••••••', icon: Icons.lock_outline_rounded,
          controller: _password, validator: Validators.password, password: true,
          enabled: !widget.viewModel.busy, textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password], onSubmitted: _submit),
        const SizedBox(height: 4),
        AuthSubmit(label: 'Log in', busy: widget.viewModel.busy, onPressed: _submit),
        const SizedBox(height: 18),
        Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('New here?', style: TextStyle(color: AppColors.muted, fontSize: 12)),
            TextButton(onPressed: widget.viewModel.busy ? null : widget.onRegister,
              child: const Text('Create an account', style: TextStyle(fontSize: 12,
                decoration: TextDecoration.underline))),
          ]),
      ]),
    )),
  );
}