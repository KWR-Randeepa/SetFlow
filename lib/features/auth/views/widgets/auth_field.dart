import 'package:flutter/material.dart';
import 'package:setflow/core/database/app_theme.dart';

class AuthField extends StatefulWidget {
  const AuthField({super.key, required this.label, required this.hint,
    required this.icon, required this.controller, required this.validator,
    this.caption, this.password = false, this.enabled = true,
    this.keyboardType, this.autofillHints, this.textInputAction = TextInputAction.next,
    this.onSubmitted});
  final String label;
  final String hint;
  final String? caption;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final bool password;
  final bool enabled;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  bool _hidden = true;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: Text(widget.label,
          style: const TextStyle(fontSize: 13, color: AppColors.muted,
            fontWeight: FontWeight.w600))),
        if (widget.caption != null)
          Text(widget.caption!, style: TextStyle(fontSize: 11,
            color: widget.caption == 'Required' ? AppColors.lime : AppColors.muted)),
      ]),
      const SizedBox(height: 8),
      TextFormField(
        controller: widget.controller,
        validator: widget.validator,
        enabled: widget.enabled,
        obscureText: widget.password && _hidden,
        autocorrect: false,
        enableSuggestions: !widget.password,
        keyboardType: widget.keyboardType,
        autofillHints: widget.autofillHints,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: (_) => widget.onSubmitted?.call(),
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: Icon(widget.icon, size: 23),
          suffixIcon: widget.password ? IconButton(
            tooltip: _hidden ? 'Show password' : 'Hide password',
            onPressed: widget.enabled ? () => setState(() => _hidden = !_hidden) : null,
            icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 22),
          ) : null,
        ),
      ),
    ]),
  );
}