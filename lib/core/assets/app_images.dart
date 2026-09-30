/// Every bundled image path in one place. Sizes and framing rules: `assets/images/README.md`.
///
/// A file that doesn't exist yet is fine: [ImageSlot] shows an icon placeholder instead, so
/// dropping the real picture in with the same name is all it takes to switch it on.
abstract final class AppImages {
  static const String logoMark = 'assets/images/brand/logo_mark.png';

  static const String onboardingProducts =
      'assets/images/onboarding/products.png';
  static const String onboardingWholesale =
      'assets/images/onboarding/wholesale.png';
  static const String onboardingDelivery =
      'assets/images/onboarding/delivery.png';

  static const String authWelcome = 'assets/images/auth/welcome.png';
  static const String authVerify = 'assets/images/auth/verify.png';
  static const String authBusiness = 'assets/images/auth/business.png';

  static const String homeCosmetics = 'assets/images/home/cosmetics.png';
  static const String homeJewelry = 'assets/images/home/jewelry.png';
  static const String homeWholesaleBanner =
      'assets/images/home/wholesale_banner.png';

  static const String orderSuccess = 'assets/images/orders/success.png';
}
