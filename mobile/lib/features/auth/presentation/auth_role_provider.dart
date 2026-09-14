import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which role is "signed in" for this demo. CEO is the only role with a real
/// dashboard today - Manager/Employee route to `ComingSoonView`. Mirrors
/// web's `authRoleStore.ts`: this is client-only UI state, not real
/// authentication. Intentionally not persisted (no `data`/`domain` layer for
/// `auth` in docs/06_MOBILE_RULES.md §6 - a demo role pick that resets on
/// app restart, same spirit as the web store being just a role label).
enum PortalRole { ceo, manager, employee }

final authRoleProvider = StateProvider<PortalRole?>((ref) => null);
