import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/features/catalog/data/models/product_query.dart';

/// Kiswahili names for the listing options, so the data enums stay free of UI text.
extension ProductSortLabel on ProductSort {
  String label(AppLocalizations l10n) => switch (this) {
    ProductSort.popular => l10n.sortPopular,
    ProductSort.newest => l10n.sortNewest,
    ProductSort.priceLowToHigh => l10n.sortPriceLow,
    ProductSort.priceHighToLow => l10n.sortPriceHigh,
  };
}

extension ProductCollectionLabel on ProductCollection {
  String label(AppLocalizations l10n) => switch (this) {
    ProductCollection.deals => l10n.quickDeals,
    ProductCollection.newArrivals => l10n.quickNewArrivals,
    ProductCollection.bestSellers => l10n.quickBestSellers,
  };
}
