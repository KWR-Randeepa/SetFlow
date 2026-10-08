import 'package:flutter/material.dart';
import 'package:setflow/core/database/app_theme.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.title, required this.subtitle,
    required this.child});
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: constraints.maxHeight > 740 ? 54 : 12),
                  Center(child: Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.lime.withValues(alpha: 0.07),
                      border: Border.all(color: AppColors.lime.withValues(alpha: 0.12), width: 5),
                      boxShadow: [BoxShadow(
                        color: AppColors.lime.withValues(alpha: 0.12),
                        blurRadius: 22,
                      )],
                    ),
                    child: const Icon(Icons.fitness_center_rounded,
                      size: 30, color: AppColors.lime),
                  )),
                  const SizedBox(height: 26),
                  Text(title, textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800,
                      letterSpacing: -1)),
                  const SizedBox(height: 10),
                  Text(subtitle, textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted, fontSize: 14, height: 1.6)),
                  const SizedBox(height: 46),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppColors.panel,
                      borderRadius: BorderRadius.circular(28)),
                    child: child,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }),
        ),
      ),
    ),
  );
}
class AuthSubmit extends StatelessWidget {
  const AuthSubmit({super.key, required this.label, required this.busy,
    required this.onPressed});
  final String label;
  final bool busy;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: busy ? null : onPressed,
    child: busy
      ? const SizedBox(width: 22, height: 22,
          child: CircularProgressIndicator(strokeWidth: 2))
      : Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label), const SizedBox(width: 10),
          const Icon(Icons.arrow_forward_rounded, size: 21),
        ]),
  );
}