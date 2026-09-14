import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/auth/presentation/login_view.dart';
import 'package:mobile/shared/theme/app_theme.dart';

void main() {
  testWidgets('LoginView renders the sign-in form and validates empty fields', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.light(), home: const LoginView()),
      ),
    );

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);

    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(find.text('Enter your email or username.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
  });
}
