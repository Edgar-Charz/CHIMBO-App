/// The fixed screens whose illustrations can be replaced from the admin app, and the logo.
enum AppImageSlot {
  /// The logo mark on the splash, login and Home header (Settings → Logo & pictures).
  logo('logo'),
  onboardingProducts('onboarding_products'),
  onboardingWholesale('onboarding_wholesale'),
  onboardingDelivery('onboarding_delivery'),
  authWelcome('auth_welcome'),
  authVerify('auth_verify'),
  authBusiness('auth_business'),
  orderSuccess('order_success');

  const AppImageSlot(this.apiValue);

  /// Shown before Home (onboarding and login): loaded during the splash so they appear at
  /// once.
  static const List<AppImageSlot> beforeHome = [
    logo,
    onboardingProducts,
    onboardingWholesale,
    onboardingDelivery,
    authWelcome,
    authVerify,
    authBusiness,
  ];

  final String apiValue;

  static AppImageSlot? fromApiValue(String value) {
    for (final slot in values) {
      if (slot.apiValue == value) return slot;
    }
    return null;
  }
}
