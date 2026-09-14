import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cache/isar_client.dart';
import '../network/dio_client.dart';

/// App-wide singletons every feature's data layer depends on. Not part of
/// any one feature, so it lives here rather than under `features/` - appended
/// to docs/06_MOBILE_RULES.md §6 alongside this change.

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

/// Overridden in `main.dart` with the real, already-opened [IsarClient]
/// (Isar.open is async, so it's awaited once at startup rather than modeled
/// as a FutureProvider every repository would have to unwrap).
final isarClientProvider = Provider<IsarClient>((ref) {
  throw UnimplementedError('isarClientProvider must be overridden in main.dart after IsarClient.open()');
});
