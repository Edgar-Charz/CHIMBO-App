// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CHIMBO';

  @override
  String get navHome => 'Home';

  @override
  String get navDiscover => 'Discover';

  @override
  String get navCart => 'Cart';

  @override
  String get navOrders => 'Orders';

  @override
  String get navProfile => 'Profile';

  @override
  String get comingSoonTitle => 'Coming soon';

  @override
  String get comingSoonMessage => 'This section will be ready soon.';

  @override
  String get pressBackAgainToExit => 'Press back again to exit.';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionAddToCart => 'Add to cart';

  @override
  String get actionRetry => 'Try again';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get phoneHint => '7XX XXX XXX';

  @override
  String priceFrom(String price) {
    return 'from $price';
  }

  @override
  String get verifiedBusiness => 'Verified';

  @override
  String get errorNetwork =>
      'No connection. Check your internet and try again.';

  @override
  String get errorTimeout => 'The connection is slow. Please try again.';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';

  @override
  String get debugOpenTools => 'Developer tools';

  @override
  String get debugTitle => 'Developer tools';

  @override
  String get debugServerSection => 'Server';

  @override
  String get debugApiAddress => 'API address';

  @override
  String get debugServerStatus => 'Server status';

  @override
  String get debugDatabaseStatus => 'Database';

  @override
  String get debugApiVersion => 'API version';

  @override
  String get debugServerTime => 'Server time';

  @override
  String get debugStatusOk => 'OK';

  @override
  String get debugStatusProblem => 'Problem';

  @override
  String get debugUiKitSection => 'UI kit';

  @override
  String get brandTaglineQuality => 'QUALITY PRODUCTS';

  @override
  String get brandTaglinePrice => 'FAIR PRICES';

  @override
  String get brandTaglineBusiness => 'STRONG BUSINESS';

  @override
  String get sloganOrder => 'Order.';

  @override
  String get sloganTrust => 'Trust.';

  @override
  String get sloganReceive => 'Receive.';

  @override
  String get sloganGrow => 'Grow your business.';

  @override
  String get categoryJewelry => 'Jewelry';

  @override
  String get categoryCosmetics => 'Cosmetics';

  @override
  String get actionGetStarted => 'Get started';

  @override
  String get onboardingProductsTitle => 'Products for Your Business';

  @override
  String get onboardingProductsSubtitle =>
      'Jewelry and cosmetics — all in one place.';

  @override
  String get onboardingWholesaleTitle => 'Wholesale Prices That Pay';

  @override
  String get onboardingWholesaleSubtitle => 'Buy more. Save more. Earn more.';

  @override
  String get onboardingSaveMore => 'SAVE MORE';

  @override
  String get onboardingDeliveryTitle => 'Order Easily. Receive Fast.';

  @override
  String get onboardingStepChoose => 'Choose';

  @override
  String get onboardingStepPay => 'Pay';

  @override
  String get onboardingStepReceive => 'Receive';

  @override
  String get onboardingDeliveryPromise =>
      'We deliver your order safely and on time.';

  @override
  String onboardingPageIndicator(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String stepProgress(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get actionBack => 'Back';

  @override
  String get actionLogout => 'Log out';

  @override
  String get optionalField => 'Optional';

  @override
  String get phoneTitle => 'Welcome to CHIMBO';

  @override
  String get phoneSubtitle => 'Start with your phone number.';

  @override
  String get phoneHelper =>
      'We use it to verify your account and deliver your orders.';

  @override
  String get phoneInvalid => 'Enter a valid phone number, e.g. 712 345 678.';

  @override
  String get termsNoticeStart => 'By continuing, you agree to the';

  @override
  String get termsLink => 'Terms';

  @override
  String get termsNoticeAnd => 'and';

  @override
  String get privacyLink => 'Privacy Policy';

  @override
  String get otpTitle => 'Verify Your Number';

  @override
  String get otpSentTo => 'We sent a verification code to';

  @override
  String otpFieldLabel(int length) {
    return '$length-digit verification code';
  }

  @override
  String get actionVerify => 'Verify';

  @override
  String get otpNotReceived => 'Didn\'t get the code?';

  @override
  String get otpResend => 'Resend';

  @override
  String otpResendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get otpResent => 'We sent a new verification code.';

  @override
  String get otpChangeNumber => 'Change number';

  @override
  String otpIncomplete(int length) {
    return 'Enter all $length digits.';
  }

  @override
  String get otpInvalid => 'The verification code is wrong. Please try again.';

  @override
  String get pinLoginTitle => 'Log in with PIN';

  @override
  String get pinLoginSubtitle => 'Enter the PIN for';

  @override
  String get actionLogin => 'Log in';

  @override
  String get pinForgot => 'Forgot PIN?';

  @override
  String get pinLockedMessage =>
      'Your PIN is locked after 5 wrong tries. We will send you an SMS code so you can set a new PIN.';

  @override
  String get createPinTitle => 'Create a PIN';

  @override
  String get resetPinTitle => 'Set a New PIN';

  @override
  String get createPinSubtitle =>
      'You will use it to log in to CHIMBO. Never share it.';

  @override
  String get pinStepCurrent => 'Enter your current PIN';

  @override
  String get pinStepNew => 'Choose a PIN of 4 to 6 digits';

  @override
  String get pinStepConfirm => 'Enter the PIN again to confirm';

  @override
  String get pinWrongLength => 'The PIN must be 4 to 6 digits.';

  @override
  String get pinMismatch => 'The PINs do not match. Try again.';

  @override
  String get pinStartOver => 'Start over';

  @override
  String get actionSavePin => 'Save PIN';

  @override
  String get menuChangePin => 'Change PIN';

  @override
  String get menuChangePinHint => 'Keep your account safe';

  @override
  String get changePinNotice =>
      'Changing your PIN logs out every other phone signed in to your account.';

  @override
  String get pinChanged => 'PIN changed.';

  @override
  String get signedOutNotice => 'You were logged out. Please log in again.';

  @override
  String pinDotsLabel(int count) {
    return 'PIN: $count digits entered';
  }

  @override
  String get businessTitle => 'Tell Us About Your Business';

  @override
  String get businessSubtitle => 'Just a few details, then you\'re in.';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get fullNameRequired => 'Enter your full name.';

  @override
  String get businessNameLabel => 'Business / shop name';

  @override
  String get regionLabel => 'Region';

  @override
  String get regionHint => 'Choose region';

  @override
  String get regionRequired => 'Choose your region.';

  @override
  String get districtLabel => 'District';

  @override
  String get locationsLoadFailed =>
      'Couldn\'t load the list. Tap to try again.';

  @override
  String get locationSearchHint => 'Search by name...';

  @override
  String get locationNoResults => 'No matching locations found.';

  @override
  String get actionEnterChimbo => 'Enter CHIMBO';

  @override
  String get businessEditLater => 'You can change these details later.';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String get comingSoonShort => 'Coming soon';

  @override
  String get profileEdit => 'Edit Profile';

  @override
  String get profileBusinessOwner => 'Business owner';

  @override
  String get profileEditPhoto => 'Change photo';

  @override
  String get menuBusinessInfo => 'Business details';

  @override
  String get menuBusinessInfoHint => 'Shop name and contacts';

  @override
  String get menuAddresses => 'Delivery addresses';

  @override
  String get menuAddressesHint => 'Where you receive orders';

  @override
  String get menuPayments => 'My payments';

  @override
  String get menuPaymentsHint => 'Payment history and accepted methods';

  @override
  String get myPaymentsTabHistory => 'History';

  @override
  String get myPaymentsTabMethods => 'Payment methods';

  @override
  String get myPaymentsEmpty =>
      'No payments yet. Payments for your orders will appear here.';

  @override
  String get acceptedMethodsTitle => 'Payment methods we accept';

  @override
  String get acceptedMethodsCash => 'Pay in cash when you receive your order.';

  @override
  String get paymentStatusSubmitted => 'Being checked';

  @override
  String get paymentStatusConfirmed => 'Confirmed';

  @override
  String get paymentStatusRejected => 'Rejected';

  @override
  String paymentOrderLine(String number, String date) {
    return 'Order #$number · $date';
  }

  @override
  String paymentReferenceLine(String reference) {
    return 'Reference: $reference';
  }

  @override
  String get menuReceipts => 'Receipts & history';

  @override
  String get menuReceiptsHint => 'See your orders and receipts';

  @override
  String get menuNotifications => 'Notifications';

  @override
  String get menuNotificationsHint => 'Order and payment updates';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get actionMarkAllRead => 'Mark all read';

  @override
  String get notificationsEmptyTitle => 'No notifications yet';

  @override
  String get notificationsEmptyMessage =>
      'We will let you know here when your order changes.';

  @override
  String get profilePhotoTitle => 'Profile photo';

  @override
  String get actionChangePhoto => 'Change photo';

  @override
  String get actionChoosePhoto => 'Choose a photo';

  @override
  String get actionTakePhoto => 'Take a photo';

  @override
  String get actionRemovePhoto => 'Remove photo';

  @override
  String get profilePhotoUploading => 'Uploading photo…';

  @override
  String get profilePhotoSaved => 'Photo saved.';

  @override
  String get profilePhotoRemoved => 'Photo removed.';

  @override
  String get receiptDownloading => 'Downloading receipt…';

  @override
  String get menuHelp => 'Help';

  @override
  String get menuHelpHint => 'Call us or get guidance';

  @override
  String get menuTerms => 'Terms and Conditions';

  @override
  String get menuTermsHint => 'The rules for using CHIMBO';

  @override
  String get menuPrivacy => 'Privacy Policy';

  @override
  String get menuPrivacyHint => 'How we protect your information';

  @override
  String get helpIntro =>
      'A question about an order, payment or your account? We are ready to help.';

  @override
  String get helpHoursTitle => 'Support hours';

  @override
  String get helpQuestionsTitle => 'Common questions';

  @override
  String helpCall(String phone) {
    return 'Call $phone';
  }

  @override
  String get helpWhatsapp => 'Message us on WhatsApp';

  @override
  String get helpCannotOpen => 'This phone has no app to open this.';

  @override
  String legalUpdatedOn(String date) {
    return 'Updated $date';
  }

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuSettingsHint => 'Language and security';

  @override
  String get logoutAccount => 'Log out';

  @override
  String get logoutConfirmTitle => 'Log out?';

  @override
  String get logoutConfirmMessage =>
      'You\'ll need your phone number to log in again.';

  @override
  String get profileSaved => 'Details saved.';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSwahili => 'Kiswahili';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsAccount => 'Account';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountHint => 'Your personal details will be removed';

  @override
  String get deleteAccountConfirmTitle => 'Delete your account?';

  @override
  String get deleteAccountConfirmMessage =>
      'This can\'t be undone. Your personal details are removed; order records stay for accounting.';

  @override
  String get greetingMorning => 'Good morning,';

  @override
  String get greetingAfternoon => 'Good afternoon,';

  @override
  String get greetingEvening => 'Good evening,';

  @override
  String greetingName(String name) {
    return '$name! 👋';
  }

  @override
  String get searchProductsHint => 'Search products...';

  @override
  String searchInCategoryHint(String category) {
    return 'Search in $category...';
  }

  @override
  String get actionBrowse => 'Browse';

  @override
  String get actionShopNow => 'Shop Now';

  @override
  String get actionViewAll => 'View all';

  @override
  String get quickDeals => 'Hot Deals';

  @override
  String get timedOffersTitle => 'Limited-time offers';

  @override
  String offerPercentLabel(int percent) {
    return 'Offer −$percent%';
  }

  @override
  String offerEndsIn(String time) {
    return 'Ends in $time';
  }

  @override
  String get quickNewArrivals => 'New Arrivals';

  @override
  String get quickBestSellers => 'Best Sellers';

  @override
  String get trendingNow => 'Trending Now';

  @override
  String get allProducts => 'All Products';

  @override
  String get quickReorder => 'Reorder';

  @override
  String get bannerTitle => 'WHOLESALE PRICES';

  @override
  String get bannerSubtitle => 'The more you buy, the more you save!';

  @override
  String get recentlyOrdered => 'Recently Ordered';

  @override
  String get chipAll => 'All';

  @override
  String get filterAction => 'Filter';

  @override
  String get sortAction => 'Sort';

  @override
  String get priceFilter => 'Price';

  @override
  String get moqFilter => 'MOQ';

  @override
  String get minPriceHint => 'Min price';

  @override
  String get maxPriceHint => 'Max price';

  @override
  String get minMoqHint => 'Min MOQ';

  @override
  String get maxMoqHint => 'Max MOQ';

  @override
  String get invalidFilterAmount => 'Enter a valid amount.';

  @override
  String get invalidFilterRange => 'Minimum must not be greater than maximum.';

  @override
  String get sortPopular => 'Most popular';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortPriceLow => 'Price: low to high';

  @override
  String get sortPriceHigh => 'Price: high to low';

  @override
  String get priceUnder5000 => 'Under TZS 5,000';

  @override
  String get price5000To10000 => 'TZS 5,000 – 10,000';

  @override
  String get priceOver10000 => 'Over TZS 10,000';

  @override
  String get moqSingle => 'MOQ 1 only';

  @override
  String get moqUpTo6 => 'MOQ up to 6';

  @override
  String get moqUpTo12 => 'MOQ up to 12';

  @override
  String get actionClearFilters => 'Clear filters';

  @override
  String get actionShowResults => 'Show products';

  @override
  String get productsEmptyTitle => 'No products';

  @override
  String get productsEmptyMessage => 'Try another word or remove filters.';

  @override
  String productMoq(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'MOQ $count pcs',
      one: 'MOQ 1 pc',
    );
    return '$_temp0';
  }

  @override
  String get verifiedSeller => 'Verified seller';

  @override
  String get badgeBestseller => 'Bestseller';

  @override
  String get badgeNew => 'New';

  @override
  String get badgeDeal => 'Deal';

  @override
  String get infoStock => 'Stock';

  @override
  String get infoDelivery => 'Delivery';

  @override
  String stockAtLeast(int count) {
    return '$count+ pcs';
  }

  @override
  String deliveryDays(int min, int max) {
    return '$min–$max days';
  }

  @override
  String get tiersTitle => 'Buy more, pay less';

  @override
  String tierRange(int min, int max) {
    return '$min–$max pcs';
  }

  @override
  String tierFrom(int min) {
    return '$min+ pcs';
  }

  @override
  String get quantityLabel => 'Quantity';

  @override
  String savingsLabel(String amount) {
    return 'You save $amount';
  }

  @override
  String nextTierHint(int count, String price) {
    return 'Add $count pcs to pay $price each';
  }

  @override
  String get actionAskSeller => 'Ask Seller';

  @override
  String get descriptionTitle => 'Description';

  @override
  String get actionFavourite => 'Favourite';

  @override
  String get actionShare => 'Share';

  @override
  String get actionZoom => 'Zoom';

  @override
  String get actionIncrease => 'Increase';

  @override
  String get actionDecrease => 'Decrease';

  @override
  String piecesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pcs',
      one: '1 pc',
    );
    return '$_temp0';
  }

  @override
  String get cartTitle => 'Your Cart';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionDone => 'Done';

  @override
  String get cartEmptyTitle => 'Your cart is empty';

  @override
  String get cartEmptyMessage =>
      'Add products to start ordering at wholesale prices.';

  @override
  String get actionStartShopping => 'Start shopping';

  @override
  String cartNudge(int count, String product, String price) {
    return 'Add $count pcs of $product to pay $price each.';
  }

  @override
  String get wholesalePriceTag => 'Wholesale price';

  @override
  String cartTierLabel(int min, String price) {
    return '$min+ pcs @ $price';
  }

  @override
  String get moqMet => 'MOQ met';

  @override
  String get actionRemove => 'Remove';

  @override
  String summaryItems(int count) {
    return 'Items ($count)';
  }

  @override
  String get summaryDelivery => 'Delivery';

  @override
  String get summaryTotal => 'Total';

  @override
  String get summaryItemsTotal => 'Items total';

  @override
  String get summaryAmountToPay => 'Amount to pay';

  @override
  String get cartDeliveryNote => 'Delivery is added at checkout.';

  @override
  String get actionContinueToCheckout => 'Continue to checkout';

  @override
  String get addedToCart => 'Added to cart.';

  @override
  String get actionViewCart => 'View cart';

  @override
  String quickAddTotal(String amount) {
    return 'Total: $amount';
  }

  @override
  String get errorMoqNotMet => 'The quantity is below this product\'s MOQ.';

  @override
  String get errorOutOfStock => 'Not enough stock for this quantity.';

  @override
  String get errorPriceChanged =>
      'Prices changed. Check the new total and confirm again.';

  @override
  String get checkoutTitle => 'Payment & Delivery';

  @override
  String get stepAddress => 'Address';

  @override
  String get stepDelivery => 'Delivery';

  @override
  String get stepPayment => 'Payment';

  @override
  String get stepReview => 'Review';

  @override
  String get deliveryAddressTitle => 'Delivery address';

  @override
  String get actionChange => 'Change';

  @override
  String get actionAddAddress => 'Add address';

  @override
  String get noAddressMessage =>
      'Add the address where you\'ll receive your order.';

  @override
  String get chooseDeliveryTitle => 'Choose delivery';

  @override
  String get deliveryTomorrow => 'tomorrow';

  @override
  String deliveryOption(String name, String eta) {
    return '$name ($eta)';
  }

  @override
  String get paymentMethodTitle => 'Payment method';

  @override
  String get payAfterOrderingHint =>
      'You will see where to pay after confirming the order.';

  @override
  String get deliveryFeeToConfirm => 'Price to be confirmed';

  @override
  String get deliveryEstimateNote =>
      'This is an estimate. We\'ll measure your load and confirm the price before you pay.';

  @override
  String get summaryTransportEstimate => 'Transport (estimate)';

  @override
  String get summaryTotalEstimate => 'Total (estimate)';

  @override
  String get summaryWeWillTellYou => 'We\'ll tell you';

  @override
  String get transportPayLaterHint =>
      'Don\'t pay yet. We\'ll measure your load and send you the final transport price, then you pay the full total.';

  @override
  String get transportPendingTitle => 'We\'re measuring your load';

  @override
  String transportPendingMessage(String region, String estimate) {
    return 'We\'re confirming the transport price to $region. The estimate is $estimate; a large load may cost more. Don\'t pay yet — we\'ll tell you the final price, then you pay here.';
  }

  @override
  String transportPendingNoEstimateMessage(String region) {
    return 'We\'re confirming the transport price to $region. Don\'t pay yet — we\'ll tell you the price, then you pay here.';
  }

  @override
  String transportFeeNote(String note) {
    return 'Transport: $note';
  }

  @override
  String get deliveryPaidToRider => 'Pay the rider';

  @override
  String get deliveryPaidToRiderNote =>
      'You pay the rider for transport when the order arrives — it isn\'t in the total.';

  @override
  String get deliveryFree => 'Free';

  @override
  String get pickupFreeLabel => 'Free (at the shop)';

  @override
  String get pickupPointTitle => 'Collect at the shop';

  @override
  String pickupPointHint(String number) {
    return 'We\'ll tell you when the order is ready. Bring order number #$number.';
  }

  @override
  String get statusReadyForPickup => 'Ready for pickup';

  @override
  String get statusPickedUp => 'Picked up';

  @override
  String get trackingReadyForPickup =>
      'Your order is ready — come and collect it at the shop.';

  @override
  String get trackingPickedUp =>
      'You collected your order. Thank you for shopping with CHIMBO!';

  @override
  String payToTitle(String amount, String method) {
    return 'Pay $amount with $method';
  }

  @override
  String get payToNumber => 'Lipa Namba / phone';

  @override
  String get payToBankAccount => 'Account number';

  @override
  String get payToAccountName => 'Account name';

  @override
  String get payToBank => 'Bank';

  @override
  String get payToNoteHint =>
      'Write this as the payment description / reference';

  @override
  String payBefore(String time) {
    return 'Pay before $time, otherwise the order is cancelled.';
  }

  @override
  String get actionCopy => 'Copy';

  @override
  String get copiedMessage => 'Copied.';

  @override
  String get actionIPaid => 'I have paid';

  @override
  String get actionChangePaymentMethod => 'Change payment method';

  @override
  String get changePaymentMethodTitle => 'Change payment method';

  @override
  String get changePaymentMethodMessage =>
      'Choose another way to pay. The time to pay does not restart.';

  @override
  String paymentMethodChanged(String method) {
    return 'You will now pay with $method.';
  }

  @override
  String get paymentMethodChangedToCash =>
      'Order confirmed. You will pay on delivery.';

  @override
  String get paymentUnderReviewTitle => 'We are checking your payment';

  @override
  String paymentUnderReviewMessage(String reference) {
    return 'We will let you know once it is confirmed. Transaction code: $reference';
  }

  @override
  String get paymentRejectedTitle => 'Payment not confirmed';

  @override
  String get paymentRejectedMessage =>
      'We could not confirm the payment. Check the details and send them again.';

  @override
  String get paymentSheetTitle => 'Confirm your payment';

  @override
  String get paymentSheetMessage =>
      'Enter the details from the payment SMS. We will check them and confirm the order.';

  @override
  String get payerPhoneLabel => 'Number you paid from';

  @override
  String get payerBankLabel => 'Account or name you paid from';

  @override
  String get paymentReferenceLabel => 'Transaction code (in the SMS)';

  @override
  String get paymentReferenceHint => 'e.g. QJK3X7ABC1';

  @override
  String get actionSendPayment => 'Send';

  @override
  String get paymentSent => 'Received. We are checking your payment.';

  @override
  String get fieldRequired => 'Fill in this field.';

  @override
  String get actionContinueToReview => 'Continue to review';

  @override
  String get reviewTitle => 'Review order';

  @override
  String get deliveryMethodTitle => 'Delivery method';

  @override
  String get orderSummaryTitle => 'Order summary';

  @override
  String get actionConfirmOrder => 'Confirm order';

  @override
  String get paymentSecure => 'Your payment is safe.';

  @override
  String get orderReceivedTitle => 'Order received!';

  @override
  String orderReceivedMessage(String name) {
    return 'Thank you, $name. We\'ve started preparing your order.';
  }

  @override
  String orderNumber(String number) {
    return '#$number';
  }

  @override
  String get actionTrackOrder => 'Track order';

  @override
  String get actionBackHome => 'Back to Home';

  @override
  String get addressFormTitle => 'New address';

  @override
  String get editAddressFormTitle => 'Edit address';

  @override
  String get addressesEmpty => 'No addresses yet';

  @override
  String get defaultAddressLabel => 'Default';

  @override
  String get addressActions => 'Address actions';

  @override
  String get actionEditAddress => 'Edit';

  @override
  String get actionSetDefaultAddress => 'Make default';

  @override
  String get deleteAddressConfirmTitle => 'Delete address?';

  @override
  String get deleteAddressConfirmMessage =>
      'This address will be removed from your delivery addresses.';

  @override
  String get recipientNameLabel => 'Recipient name';

  @override
  String get streetLabel => 'Street / area';

  @override
  String get streetHint => 'E.g. Kariakoo, Lumumba Street';

  @override
  String get streetRequired => 'Enter the street or area.';

  @override
  String get landmarkLabel => 'Nearby landmark';

  @override
  String get actionSaveAddress => 'Save address';

  @override
  String get chooseAddressTitle => 'Choose address';

  @override
  String get ordersTitle => 'My Orders';

  @override
  String get tabActiveOrders => 'Active';

  @override
  String get tabDeliveredOrders => 'Delivered';

  @override
  String get ordersEmptyTitle => 'No orders here';

  @override
  String get ordersEmptyMessage => 'Your orders will show here.';

  @override
  String get statusPendingPayment => 'Awaiting payment';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusPacked => 'Packed';

  @override
  String get statusDispatched => 'Dispatched';

  @override
  String get statusInTransit => 'In transit';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusExpired => 'Expired';

  @override
  String get trackingPendingPayment =>
      'Complete payment so we can start preparing your order.';

  @override
  String get trackingConfirmed => 'We\'re preparing your order.';

  @override
  String get trackingPacked => 'Your order is ready to go.';

  @override
  String get trackingDispatched => 'Your order is with the delivery agent.';

  @override
  String get trackingInTransitTitle => 'On the way';

  @override
  String get trackingInTransit => 'Your order is coming.';

  @override
  String get trackingDelivered => 'Thanks for buying with CHIMBO!';

  @override
  String get trackingCancelled => 'This order was cancelled.';

  @override
  String get trackingExpired => 'The payment time ran out.';

  @override
  String get estimatedDeliveryTitle => 'Estimated delivery';

  @override
  String get deliveredOnTitle => 'Delivered on';

  @override
  String get actionDownloadReceipt => 'Download receipt';

  @override
  String get reorderDone => 'The items are back in your cart.';

  @override
  String get deliveryAgentTitle => 'Delivery agent';

  @override
  String get actionCall => 'Call';

  @override
  String get actionMessage => 'Message';

  @override
  String get actionCancelOrder => 'Cancel order';

  @override
  String get cancelOrderConfirmTitle => 'Cancel this order?';

  @override
  String get cancelOrderConfirmMessage =>
      'The order is cancelled and the items go back to stock. This can\'t be undone.';

  @override
  String get orderCancelledMessage => 'Order cancelled.';

  @override
  String orderItemLine(int quantity, String price) {
    return '$quantity × $price';
  }

  @override
  String get savedToWishlist => 'Saved to your favourites.';

  @override
  String get actionUnfavourite => 'Remove from favourites';

  @override
  String discountPercent(int percent) {
    return '-$percent%';
  }

  @override
  String get menuWishlist => 'Favourites';

  @override
  String get menuWishlistHint => 'Products you saved';

  @override
  String get wishlistEmptyTitle => 'No favourites yet';

  @override
  String get wishlistEmptyMessage => 'Tap ♡ on a product to save it here.';

  @override
  String get outOfStock => 'Sold out';

  @override
  String get actionOutOfStock => 'Out of stock';

  @override
  String otpTestModeHint(String code) {
    return 'Test mode: the code is $code';
  }

  @override
  String cartProblemNotEnoughStock(int count) {
    return 'Not enough stock — $count left';
  }

  @override
  String cartProblemBelowMoq(int moq) {
    return 'Below the MOQ ($moq)';
  }

  @override
  String cartFixLowerTo(int count) {
    return 'Lower to $count';
  }

  @override
  String cartFixRaiseTo(int count) {
    return 'Raise to $count';
  }

  @override
  String get cartCannotCheckout => 'Fix the items marked in red to continue.';

  @override
  String get summarySavings => 'You save';
}
