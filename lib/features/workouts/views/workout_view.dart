import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../auth/viewmodels/auth_view_model.dart';
import '../viewmodels/workout_view_model.dart';

class WorkoutView extends StatefulWidget {
  const WorkoutView({super.key, required this.auth, required this.viewModel});
  final AuthViewModel auth;
  final WorkoutViewModel viewModel;
  @override
  State<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
  final _title = TextEditingController();
  final _form = GlobalKey<FormState>();

  Future<void> _add() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    if (await widget.viewModel.add(_title.text) && mounted) {
      _title.clear();
      _form.currentState!.reset();
    }
  }

  @override
  void dispose() { _title.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([widget.auth, widget.viewModel]),
    builder: (context, _) {
      final vm = widget.viewModel;
      final locked = vm.busy || widget.auth.busy;
      return Scaffold(
        appBar: AppBar(title: const Text('Your routine'), actions: [
          IconButton(tooltip: 'Log out',
            onPressed: locked ? null : () => widget.auth.logout(),
            icon: const Icon(Icons.logout_rounded)),
        ]),
        body: SafeArea(child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(padding: const EdgeInsets.all(24), children: [
            Text('Hi, ${widget.auth.user?.fullName ?? ''}',
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            const Text('Small steps. Stronger habits.', style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 24),
            Text('${vm.items.where((e) => e.done).length} of ${vm.items.length} completed',
              style: const TextStyle(color: AppColors.lime)),
            const SizedBox(height: 20),
            Form(key: _form, child: TextFormField(
              controller: _title, enabled: !locked, maxLength: 100,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _add(),
              validator: (value) => (value ?? '').trim().isEmpty
                  ? 'Enter an exercise name.' : null,
              decoration: const InputDecoration(hintText: 'e.g. Push-ups — 3 × 10',
                prefixIcon: Icon(Icons.fitness_center_rounded)),
            )),
            const SizedBox(height: 8),
            FilledButton.icon(onPressed: locked ? null : _add,
              icon: const Icon(Icons.add_rounded), label: const Text('Add exercise')),
            if (vm.busy) const Padding(padding: EdgeInsets.only(top: 20),
              child: LinearProgressIndicator()),
            if (vm.error != null || widget.auth.error != null) Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(vm.error ?? widget.auth.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
            if (vm.error != null) TextButton(onPressed: locked ? null : () => vm.load(),
              child: const Text('Retry loading')),
            const SizedBox(height: 24),
            if (vm.items.isEmpty && !vm.busy && vm.error == null)
              const Padding(padding: EdgeInsets.symmetric(vertical: 32),
                child: Column(children: [
                  Icon(Icons.playlist_add_check_rounded, size: 64, color: AppColors.lime),
                  SizedBox(height: 12), Text('Your first exercise starts here.'),
                ])),
            ...vm.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CheckboxListTile(
                key: ValueKey(item.id), tileColor: AppColors.panel,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                title: Text(item.title, style: TextStyle(
                  decoration: item.done ? TextDecoration.lineThrough : null)),
                value: item.done, onChanged: locked ? null : (_) => vm.toggle(item),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            )),
          ]),
        ))),
      );
    },
  );
}