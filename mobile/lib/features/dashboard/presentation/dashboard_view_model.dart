import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/org_local_data_source.dart';
import '../data/org_remote_data_source.dart';
import '../data/org_repository_impl.dart';
import '../domain/entities/org_insights.dart';
import '../domain/entities/org_summary.dart';
import '../domain/repositories/org_repository.dart';
import '../domain/use_cases/get_org_dashboard.dart';
import '../domain/use_cases/get_org_insights.dart';

// --- Data-layer wiring -------------------------------------------------

final _orgRemoteDataSourceProvider = Provider(
  (ref) => OrgRemoteDataSource(ref.watch(dioClientProvider)),
);

final _orgLocalDataSourceProvider = Provider(
  (ref) => OrgLocalDataSource(ref.watch(isarClientProvider)),
);

final orgRepositoryProvider = Provider<OrgRepository>(
  (ref) => OrgRepositoryImpl(
    ref.watch(_orgRemoteDataSourceProvider),
    ref.watch(_orgLocalDataSourceProvider),
  ),
);

// --- Use cases -----------------------------------------------------------

final _getOrgDashboardProvider = Provider((ref) => GetOrgDashboard(ref.watch(orgRepositoryProvider)));

final _getOrgInsightsProvider = Provider((ref) => GetOrgInsights(ref.watch(orgRepositoryProvider)));

// --- ViewModel (screen state) --------------------------------------------

/// Org-wide dashboard tiles + history (`org_dashboard`).
final orgDashboardProvider = FutureProvider<OrgSummary>((ref) => ref.watch(_getOrgDashboardProvider)());

/// Dashboard insight chips (`org_insights`).
final orgInsightsProvider = FutureProvider<OrgInsights>((ref) => ref.watch(_getOrgInsightsProvider)());
