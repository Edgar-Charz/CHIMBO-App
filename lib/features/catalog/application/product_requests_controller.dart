import 'package:chimbo/core/storage/token_storage.dart';
import 'package:chimbo/features/catalog/data/catalog_repository.dart';
import 'package:chimbo/features/catalog/data/models/product_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Customer request history, excluding requests they have cancelled.
class ProductRequestsController extends AsyncNotifier<List<ProductRequest>> {
  CatalogRepository get _repository => ref.read(catalogRepositoryProvider);

  @override
  Future<List<ProductRequest>> build() => _repository.getProductRequests();

  Future<void> cancel(int requestId) async {
    await _repository.cancelProductRequest(requestId);
    state = AsyncData(await _repository.getProductRequests());
  }
}

final productRequestsControllerProvider =
    AsyncNotifierProvider.autoDispose<
      ProductRequestsController,
      List<ProductRequest>
    >(ProductRequestsController.new);

final productRequestImageHeadersProvider =
    FutureProvider.autoDispose<Map<String, String>>((ref) async {
      final token = await ref.read(tokenStorageProvider).readToken();
      return token == null ? const {} : {'Authorization': 'Bearer $token'};
    });
