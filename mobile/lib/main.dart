import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/cache/isar_client.dart';
import 'core/providers/core_providers.dart';
import 'features/auth/presentation/login_view.dart';
import 'shared/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isarClient = await IsarClient.open();

  runApp(
    ProviderScope(
      overrides: [isarClientProvider.overrideWithValue(isarClient)],
      child: const AnalyticsPortalApp(),
    ),
  );
}

class AnalyticsPortalApp extends StatelessWidget {
  const AnalyticsPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Analytics Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const LoginView(),
    );
  }
}
