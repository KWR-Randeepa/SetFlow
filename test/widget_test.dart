import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setflow/core/app_theme.dart';
import 'package:setflow/features/auth/viewmodels/auth_view_model.dart';
import 'package:setflow/features/auth/views/auth_flow.dart';
import 'auth_view_model_test.dart' show FakeAuthRepository;

void main() {
  testWidgets('login page is default landing page and navigates to register', (tester) async {
    final vm = AuthViewModel(FakeAuthRepository());
    await vm.restoreSession();
    await tester.pumpWidget(MaterialApp(theme: buildAppTheme(),
      home: AuthFlow(viewModel: vm)));
    expect(find.text('Welcome back.'), findsOneWidget);
    final registerLink = find.widgetWithText(TextButton, 'Create an account');
    await tester.ensureVisible(registerLink);
    await tester.tap(registerLink);
    await tester.pumpAndSettle();
    expect(find.text('Build your routine.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    vm.dispose();
  });

  testWidgets('register validation and login navigation on a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final vm = AuthViewModel(FakeAuthRepository());
    await vm.restoreSession();
    await tester.pumpWidget(MaterialApp(theme: buildAppTheme(),
      home: AuthFlow(viewModel: vm, initialRegister: true)));
    expect(find.text('Build your routine.'), findsOneWidget);
    final create = find.widgetWithText(FilledButton, 'Create account');
    await tester.ensureVisible(create);
    await tester.tap(create);
    await tester.pumpAndSettle();
    expect(find.text('Enter your full name.'), findsOneWidget);
    final login = find.widgetWithText(TextButton, 'Log in');
    await tester.ensureVisible(login);
    await tester.tap(login);
    await tester.pumpAndSettle();
    expect(find.text('Welcome back.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    vm.dispose();
  });
}