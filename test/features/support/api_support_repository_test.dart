import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/features/support/data/api_support_repository.dart';
import 'package:chimbo/features/support/data/models/legal_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http.dart';

void main() {
  test('Msaada reads the phone, WhatsApp link and hours', () async {
    final (client, adapter) = clientReplying(
      (_) => jsonReply({
        'success': true,
        'data': {
          'support_phone': '+255700111222',
          'support_whatsapp': '+255700111222',
          'support_whatsapp_url': 'https://wa.me/255700111222',
          'support_hours': 'Jumatatu–Jumamosi, saa 2 asubuhi – saa 12 jioni',
        },
      }),
    );

    final contacts = await ApiSupportRepository(client).getContacts();

    expect(adapter.lastRequest!.uri.path, endsWith('/support'));
    expect(contacts.phone, '+255700111222');
    expect(contacts.whatsappUrl, 'https://wa.me/255700111222');
  });

  test('a page body becomes paragraphs at the empty lines', () async {
    final (client, adapter) = clientReplying(
      (_) => jsonReply({
        'success': true,
        'data': {
          'page_title': 'Vigezo na Masharti',
          // Windows line endings, a blank line with spaces and a trailing gap.
          'page_body': '1. Utangulizi\nMstari wa pili.\r\n\r\n2. Oda\n  \n<b>Si HTML</b>\n\n',
          'updated_at': '2026-10-01T08:00:00+00:00',
        },
      }),
    );

    final page = await ApiSupportRepository(client)
        .getPage(LegalPageType.terms);

    expect(adapter.lastRequest!.uri.path, endsWith('/pages/terms'));
    expect(page.title, 'Vigezo na Masharti');
    expect(page.paragraphs, [
      '1. Utangulizi\nMstari wa pili.',
      '2. Oda',
      // Shown as plain text, never interpreted.
      '<b>Si HTML</b>',
    ]);
  });

  test('an unknown page is NOT_FOUND', () async {
    final (client, _) = clientReplying(
      (_) => jsonReply({
        'success': false,
        'error': {'code': 'NOT_FOUND', 'message': 'Ukurasa haupo.'},
      }, statusCode: 404),
    );

    await expectLater(
      ApiSupportRepository(client).getPage(LegalPageType.privacy),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 'NOT_FOUND')),
    );
  });
}
