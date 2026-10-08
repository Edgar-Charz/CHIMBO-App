import 'package:chimbo/core/network/api_client.dart';
import 'package:chimbo/features/support/data/models/legal_page.dart';
import 'package:chimbo/features/support/data/models/support_contacts.dart';
import 'package:chimbo/features/support/data/support_repository.dart';

/// Support contacts and legal pages from the CHIMBO API (docs/API_REFERENCE.md, "Support and
/// legal pages").
class ApiSupportRepository implements SupportRepository {
  const ApiSupportRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<SupportContacts> getContacts() async {
    final response = await _apiClient.get('/support');
    return SupportContacts.fromJson(response.dataAsMap);
  }

  @override
  Future<LegalPage> getPage(LegalPageType type) async {
    final response = await _apiClient.get('/pages/${type.apiValue}');
    return LegalPage.fromJson(response.dataAsMap);
  }
}
