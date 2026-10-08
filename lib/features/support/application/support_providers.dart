import 'package:chimbo/features/support/data/models/legal_page.dart';
import 'package:chimbo/features/support/data/models/support_contacts.dart';
import 'package:chimbo/features/support/data/support_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Msaada's phone, WhatsApp link and hours.
final supportContactsProvider = FutureProvider.autoDispose<SupportContacts>(
  (ref) => ref.watch(supportRepositoryProvider).getContacts(),
);

/// One legal page, loaded each time it is opened (the text can change on the server).
final legalPageProvider = FutureProvider.autoDispose
    .family<LegalPage, LegalPageType>(
      (ref, type) => ref.watch(supportRepositoryProvider).getPage(type),
    );
