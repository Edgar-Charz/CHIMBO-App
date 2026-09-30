/// Every route path in one place, so screens never hard-code URLs.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String phone = '/auth/phone';
  static const String otp = '/auth/otp';
  static const String businessInfo = '/auth/business';
  static const String home = '/home';
  static const String discover = '/discover';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String settings = '/profile/settings';
  static const String wishlist = '/profile/wishlist';
  static const String checkout = '/cart/checkout';
  static const String checkoutReview = '/cart/checkout/review';
  static const String addressForm = '/cart/checkout/address';
  static const String orderPattern = '/orders/:orderId';
  static const String orderSuccessPattern = '/order-success/:orderId';
  static const String debug = '/debug';

  /// Pattern for the router; screens build real paths with the helpers below.
  static const String categoryPattern = '/discover/category/:categoryId';
  static const String productPattern = '/product/:productId';

  /// Gundua listing of one category (inside the Gundua tab, as in the design).
  static String category(int categoryId) => '/discover/category/$categoryId';

  /// A category-scoped collection listing, opened by a category section's "View all" action.
  static String categoryListing(int categoryId, {String? collection}) =>
      '/discover/category/$categoryId?listing=1'
      '${collection == null ? '' : '&collection=$collection'}';

  static String productDetails(int productId) => '/product/$productId';

  /// Fuatilia Oda (inside the Oda tab).
  static String orderDetails(int orderId) => '/orders/$orderId';

  /// "Oda Imepokelewa!" — full screen, after Thibitisha Oda.
  static String orderSuccess(int orderId) => '/order-success/$orderId';

  /// Gundua listing of a Home collection (Ofa, Bidhaa Mpya, Zinazouzwa Sana).
  static String collection(String apiValue) => '$discover?collection=$apiValue';
}
