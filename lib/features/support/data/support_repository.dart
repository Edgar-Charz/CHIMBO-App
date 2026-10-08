import 'package:chimbo/core/network/network_providers.dart';
import 'package:chimbo/features/support/data/api_support_repository.dart';
import 'package:chimbo/features/support/data/models/legal_page.dart';
import 'package:chimbo/features/support/data/models/support_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Msaada and the legal pages (public, no login needed). Every method throws `ApiException`.
abstract interface class SupportRepository {
  /// `GET /support`.
  Future<SupportContacts> getContacts();

  /// `GET /pages/terms` or `/pages/privacy`.
  Future<LegalPage> getPage(LegalPageType type);
}

final supportRepositoryProvider = Provider<SupportRepository>(
  (ref) => ApiSupportRepository(ref.watch(apiClientProvider)),
);
