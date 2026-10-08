import 'package:chimbo/features/support/data/models/legal_page.dart';
import 'package:chimbo/features/support/data/models/support_contacts.dart';
import 'package:chimbo/features/support/data/support_repository.dart';

/// Offline stand-in for `/support` and `/pages/{name}`.
class FakeSupportRepository implements SupportRepository {
  const FakeSupportRepository();

  @override
  Future<SupportContacts> getContacts() async => const SupportContacts(
    phone: '+255700111222',
    whatsappUrl: 'https://wa.me/255700111222',
    hours: 'Jumatatu–Jumamosi, saa 2 asubuhi – saa 12 jioni',
  );

  @override
  Future<LegalPage> getPage(LegalPageType type) async => LegalPage(
    title: switch (type) {
      LegalPageType.terms => 'Vigezo na Masharti',
      LegalPageType.privacy => 'Sera ya Faragha',
    },
    paragraphs: const ['Aya ya kwanza.', 'Aya ya pili.'],
    updatedAt: DateTime(2026, 10),
  );
}
