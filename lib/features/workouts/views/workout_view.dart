import 'package:flutter/material.dart';
import '../../../core/app\\\_theme.dart';
import '../../auth/viewmodels/auth\\\_view\\\_model.dart';
import '../viewmodels/workout\\\_view\\\_model.dart';

class WorkoutView extends StatefulWidget {
  const WorkoutView({super.key, required this.auth, required this.viewModel});
  final AuthViewModel auth;
  final WorkoutViewModel viewModel;
  @override
  State<WorkoutView> createState() => \\\_WorkoutViewState();
}

class \\\_WorkoutViewState extends State<WorkoutView> {
  final \\\_title = TextEditingController();
  final \\\_form = GlobalKey<FormState>();

  Future<void> \\\_add() async {
    if (!\\\_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    if (await widget.viewModel.add(\\\_title.text) \\\&\\\& mounted) {
      \\\_title.clear();
      \\\_form.currentState!.reset();
    }
  }

