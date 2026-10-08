/// The fixed screens whose illustrations can be replaced from the admin app.
enum AppImageSlot {
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
