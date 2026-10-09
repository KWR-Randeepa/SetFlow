import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../core/validators.dart';
import '../viewmodels/auth_view_model.dart';
import 'widgets/auth_field.dart';
import 'widgets/auth_layout.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key, required this.viewModel, required this.onLogin,
    required this.onRegistered});
  final AuthViewModel viewModel;
  final VoidCallback onLogin;
  final ValueChanged<String> onRegistered;
  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  Future<void> _submit() async {
    if (widget.viewModel.busy || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final success = await widget.viewModel.register(
      fullName: _name.text, email: _email.text,
      password: _password.text, confirmPassword: _confirm.text);
    if (!mounted || !success) return;
    widget.onRegistered(_email.text.trim());
  }

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _password.dispose(); _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AuthLayout(
    title: 'Build your routine.',
    subtitle: 'Save your exercises and track what you\nfinish.',
    child: AutofillGroup(child: Form(key: _form,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        AuthError(widget.viewModel.error),
        AuthField(label: 'Full Name', caption: 'Required', hint: 'e.g. Alex Morgan',
          icon: Icons.person_outline_rounded, controller: _name,
          validator: Validators.name, enabled: !widget.viewModel.busy,
          autofillHints: const [AutofillHints.name]),
        AuthField(label: 'Email Address', caption: 'Local ID', hint: 'alex@example.com',
          icon: Icons.mail_outline_rounded, controller: _email,
          validator: Validators.email, enabled: !widget.viewModel.busy,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email]),
        AuthField(label: 'Password', caption: 'Min. 6 chars', hint: '••••••••',
          icon: Icons.lock_outline_rounded, controller: _password,
          password: true, validator: Validators.password,
          enabled: !widget.viewModel.busy,
          autofillHints: const [AutofillHints.newPassword]),
        AuthField(label: 'Confirm Password', caption: 'Match', hint: '••••••••',
          icon: Icons.verified_user_outlined, controller: _confirm, password: true,
          validator: (value) => Validators.confirmPassword(value, _password.text),
          enabled: !widget.viewModel.busy, textInputAction: TextInputAction.done,
          onSubmitted: _submit),
        const SizedBox(height: 4),
        AuthSubmit(label: 'Create account', busy: widget.viewModel.busy,
          onPressed: _submit),
        const SizedBox(height: 18),
        Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Already have an account?',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
            TextButton(onPressed: widget.viewModel.busy ? null : widget.onLogin,
              child: const Text('Log in', style: TextStyle(fontSize: 12,
                decoration: TextDecoration.underline))),
          ]),
      ]),
    )),
  );
}


