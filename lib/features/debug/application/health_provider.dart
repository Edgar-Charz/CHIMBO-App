import 'package:chimbo/features/debug/data/health_status.dart';
import 'package:chimbo/features/debug/data/system_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loads the server health when the debug screen opens; `ref.invalidate` checks again.
final healthProvider = FutureProvider.autoDispose<HealthStatus>(
  (ref) => ref.watch(systemRepositoryProvider).fetchHealth(),
);
