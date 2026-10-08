// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appTitle => 'CHIMBO';

  @override
  String get navHome => 'Nyumbani';

  @override
  String get navDiscover => 'Gundua';

  @override
  String get navCart => 'Kikapu';

  @override
  String get navOrders => 'Oda';

  @override
  String get navProfile => 'Wasifu';

  @override
  String get comingSoonTitle => 'Inakuja hivi karibuni';

  @override
  String get comingSoonMessage => 'Sehemu hii itakuwa tayari hivi punde.';

  @override
  String get pressBackAgainToExit => 'Bonyeza nyuma tena ili kutoka.';

  @override
  String get actionContinue => 'Endelea';

  @override
  String get actionAddToCart => 'Ongeza Kikapuni';

  @override
  String get actionRetry => 'Jaribu tena';

  @override
  String get phoneLabel => 'Namba ya simu';

  @override
  String get phoneHint => '7XX XXX XXX';

  @override
  String priceFrom(String price) {
    return 'kuanzia $price';
  }

  @override
  String get verifiedBusiness => 'Imethibitishwa';

  @override
  String get errorNetwork =>
      'Hakuna mtandao. Angalia intaneti yako kisha ujaribu tena.';

  @override
  String get errorTimeout => 'Mtandao uko polepole. Tafadhali jaribu tena.';

  @override
  String get errorUnknown => 'Kuna tatizo limetokea. Tafadhali jaribu tena.';

  @override
  String get debugOpenTools => 'Zana za wasanidi';

  @override
  String get debugTitle => 'Zana za wasanidi';

  @override
  String get debugServerSection => 'Seva';

  @override
  String get debugApiAddress => 'Anwani ya API';

  @override
  String get debugServerStatus => 'Hali ya seva';

  @override
  String get debugDatabaseStatus => 'Hifadhidata';

  @override
  String get debugApiVersion => 'Toleo la API';

  @override
  String get debugServerTime => 'Muda wa seva';

  @override
  String get debugStatusOk => 'Iko sawa';

  @override
  String get debugStatusProblem => 'Ina tatizo';

  @override
  String get debugUiKitSection => 'Vipengele vya muonekano';

  @override
  String get brandTaglineQuality => 'BIDHAA BORA';

  @override
  String get brandTaglinePrice => 'BEI NAFUU';

  @override
  String get brandTaglineBusiness => 'BIASHARA IMARA';

  @override
  String get sloganOrder => 'Agiza.';

  @override
  String get sloganTrust => 'Amini.';

  @override
  String get sloganReceive => 'Pokea.';

  @override
  String get sloganGrow => 'Kuza Biashara.';

  @override
  String get categoryJewelry => 'Jewelry';

  @override
  String get categoryCosmetics => 'Cosmetics';

  @override
  String get actionGetStarted => 'Anza Sasa';

  @override
  String get onboardingProductsTitle => 'Bidhaa za Biashara Yako';

  @override
  String get onboardingProductsSubtitle =>
      'Jewelry na Cosmetics — zote sehemu moja.';

  @override
  String get onboardingWholesaleTitle => 'Bei za Jumla Zinazokulipa';

  @override
  String get onboardingWholesaleSubtitle =>
      'Nunua zaidi. Okoa zaidi. Pata faida zaidi.';

  @override
  String get onboardingSaveMore => 'OKOA ZAIDI';

  @override
  String get onboardingDeliveryTitle => 'Agiza kwa Urahisi. Pokea Haraka.';

  @override
  String get onboardingStepChoose => 'Chagua';

  @override
  String get onboardingStepPay => 'Lipa';

  @override
  String get onboardingStepReceive => 'Pokea';

  @override
  String get onboardingDeliveryPromise =>
      'Tunafikisha oda yako salama na kwa wakati.';

  @override
  String onboardingPageIndicator(int current, int total) {
    return 'Ukurasa $current kati ya $total';
  }

  @override
  String stepProgress(int current, int total) {
    return 'Hatua $current kati ya $total';
  }

  @override
  String get actionBack => 'Rudi';

  @override
  String get actionLogout => 'Toka';

  @override
  String get optionalField => 'Si lazima';

  @override
  String get phoneTitle => 'Karibu CHIMBO';

  @override
  String get phoneSubtitle => 'Anza kwa namba yako ya simu.';

  @override
  String get phoneHelper =>
      'Tutaitumia kuthibitisha akaunti na kukufikishia oda.';

  @override
  String get phoneInvalid => 'Weka namba sahihi ya simu, mfano 712 345 678.';

  @override
  String get termsNoticeStart => 'Kwa kuendelea, unakubali';

  @override
  String get termsLink => 'Masharti';

  @override
  String get termsNoticeAnd => 'na';

  @override
  String get privacyLink => 'Sera ya Faragha';

  @override
  String get otpTitle => 'Thibitisha Namba';

  @override
  String get otpSentTo => 'Tumeweka namba ya uthibitisho kwenye';

  @override
  String otpFieldLabel(int length) {
    return 'Namba ya uthibitisho ya tarakimu $length';
  }

  @override
  String get actionVerify => 'Thibitisha';

  @override
  String get otpNotReceived => 'Hukupokea namba?';

  @override
  String get otpResend => 'Tuma tena';

  @override
  String otpResendIn(int seconds) {
    return 'Tuma tena baada ya ${seconds}s';
  }

  @override
  String get otpResent => 'Tumetuma namba mpya ya uthibitisho.';

  @override
  String get otpChangeNumber => 'Badilisha namba';

  @override
  String otpIncomplete(int length) {
    return 'Weka tarakimu zote $length.';
  }

  @override
  String get otpInvalid => 'Namba ya uthibitisho si sahihi. Jaribu tena.';

  @override
  String get pinLoginTitle => 'Ingia kwa PIN';

  @override
  String get pinLoginSubtitle => 'Weka PIN ya akaunti ya';

  @override
  String get actionLogin => 'Ingia';

  @override
  String get pinForgot => 'Umesahau PIN?';

  @override
  String get pinLockedMessage =>
      'PIN imefungwa baada ya majaribio 5 yasiyo sahihi. Tutakutumia namba kwa SMS ili uweke PIN mpya.';

  @override
  String get createPinTitle => 'Tengeneza PIN';

  @override
  String get resetPinTitle => 'Weka PIN Mpya';

  @override
  String get createPinSubtitle =>
      'Utaitumia kuingia CHIMBO kila mara. Usimwambie mtu yeyote.';

  @override
  String get pinStepCurrent => 'Weka PIN yako ya sasa';

  @override
  String get pinStepNew => 'Chagua PIN ya tarakimu 4 hadi 6';

  @override
  String get pinStepConfirm => 'Rudia PIN ili kuthibitisha';

  @override
  String get pinWrongLength => 'PIN iwe tarakimu 4 hadi 6.';

  @override
  String get pinMismatch => 'PIN hazilingani. Rudia tena.';

  @override
  String get pinStartOver => 'Anza upya';

  @override
  String get actionSavePin => 'Hifadhi PIN';

  @override
  String get menuChangePin => 'Badilisha PIN';

  @override
  String get menuChangePinHint => 'Linda akaunti yako';

  @override
  String get changePinNotice =>
      'Ukibadilisha PIN, simu nyingine zote zilizoingia kwenye akaunti yako zitatolewa.';

  @override
  String get pinChanged => 'PIN imebadilishwa.';

  @override
  String get signedOutNotice =>
      'Umetolewa kwenye akaunti. Tafadhali ingia tena.';

  @override
  String pinDotsLabel(int count) {
    return 'PIN: tarakimu $count zimewekwa';
  }

  @override
  String get businessTitle => 'Tuambie Kuhusu Biashara Yako';

  @override
  String get businessSubtitle => 'Taarifa chache tu, kisha unaanza.';

  @override
  String get fullNameLabel => 'Jina kamili';

  @override
  String get fullNameRequired => 'Andika jina lako kamili.';

  @override
  String get businessNameLabel => 'Jina la biashara / duka';

  @override
  String get regionLabel => 'Mkoa';

  @override
  String get regionHint => 'Chagua mkoa';

  @override
  String get regionRequired => 'Chagua mkoa wako.';

  @override
  String get districtLabel => 'Wilaya';

  @override
  String get locationsLoadFailed =>
      'Imeshindikana kupakia orodha. Gusa kujaribu tena.';

  @override
  String get locationSearchHint => 'Tafuta kwa jina...';

  @override
  String get locationNoResults =>
      'Hakuna eneo linalolingana na utafutaji wako.';

  @override
  String get actionEnterChimbo => 'Ingia CHIMBO';

  @override
  String get businessEditLater => 'Unaweza kubadilisha taarifa hizi baadaye.';

  @override
  String get actionCancel => 'Ghairi';

  @override
  String get actionSave => 'Hifadhi';

  @override
  String get actionDelete => 'Futa';

  @override
  String get comingSoonShort => 'Inakuja';

  @override
  String get profileEdit => 'Hariri Wasifu';

  @override
  String get profileBusinessOwner => 'Mmiliki wa Biashara';

  @override
  String get profileEditPhoto => 'Badilisha picha';

  @override
  String get menuBusinessInfo => 'Taarifa za Biashara';

  @override
  String get menuBusinessInfoHint => 'Jina la duka na mawasiliano';

  @override
  String get menuAddresses => 'Anwani za Usafirishaji';

  @override
  String get menuAddressesHint => 'Mahali pa kupokea oda';

  @override
  String get menuPayments => 'Njia za Malipo';

  @override
  String get menuPaymentsHint => 'Simamia malipo yako';

  @override
  String get menuReceipts => 'Risiti na Historia';

  @override
  String get menuReceiptsHint => 'Ona oda na risiti zako';

  @override
  String get menuNotifications => 'Arifa';

  @override
  String get menuNotificationsHint => 'Chagua taarifa unazotaka';

  @override
  String get notificationsTitle => 'Arifa';

  @override
  String get actionMarkAllRead => 'Soma zote';

  @override
  String get notificationsEmptyTitle => 'Hakuna arifa bado';

  @override
  String get notificationsEmptyMessage =>
      'Tutakujulisha hapa hali ya oda yako ikibadilika.';

  @override
  String get profilePhotoTitle => 'Picha ya wasifu';

  @override
  String get actionChangePhoto => 'Badilisha picha';

  @override
  String get actionChoosePhoto => 'Chagua picha';

  @override
  String get actionTakePhoto => 'Piga picha';

  @override
  String get actionRemovePhoto => 'Ondoa picha';

  @override
  String get profilePhotoUploading => 'Inapakia picha…';

  @override
  String get profilePhotoSaved => 'Picha imehifadhiwa.';

  @override
  String get profilePhotoRemoved => 'Picha imeondolewa.';

  @override
  String get receiptDownloading => 'Inapakua risiti…';

  @override
  String get menuHelp => 'Msaada';

  @override
  String get menuHelpHint => 'Piga simu au pata maelekezo';

  @override
  String get menuTerms => 'Vigezo na Masharti';

  @override
  String get menuTermsHint => 'Masharti ya kutumia CHIMBO';

  @override
  String get menuPrivacy => 'Sera ya Faragha';

  @override
  String get menuPrivacyHint => 'Jinsi tunavyolinda taarifa zako';

  @override
  String get helpIntro =>
      'Una swali kuhusu oda, malipo au akaunti yako? Tuko tayari kukusaidia.';

  @override
  String get helpHoursTitle => 'Saa za huduma';

  @override
  String helpCall(String phone) {
    return 'Piga simu $phone';
  }

  @override
  String get helpWhatsapp => 'Tuma ujumbe WhatsApp';

  @override
  String get helpCannotOpen => 'Simu hii haina programu ya kufungua hiki.';

  @override
  String legalUpdatedOn(String date) {
    return 'Imesasishwa $date';
  }

  @override
  String get menuSettings => 'Mipangilio';

  @override
  String get menuSettingsHint => 'Lugha na usalama';

  @override
  String get logoutAccount => 'Toka kwenye Akaunti';

  @override
  String get logoutConfirmTitle => 'Toka kwenye akaunti?';

  @override
  String get logoutConfirmMessage =>
      'Utahitaji namba yako ya simu kuingia tena.';

  @override
  String get profileSaved => 'Taarifa zimehifadhiwa.';

  @override
  String get settingsLanguage => 'Lugha';

  @override
  String get languageSwahili => 'Kiswahili';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsAccount => 'Akaunti';

  @override
  String get deleteAccount => 'Futa akaunti';

  @override
  String get deleteAccountHint => 'Taarifa zako binafsi zitafutwa';

  @override
  String get deleteAccountConfirmTitle => 'Futa akaunti yako?';

  @override
  String get deleteAccountConfirmMessage =>
      'Hatua hii haiwezi kurudishwa. Taarifa zako binafsi zitafutwa; rekodi za oda zinabaki kwa ajili ya hesabu.';

  @override
  String get greetingMorning => 'Habari za asubuhi,';

  @override
  String get greetingAfternoon => 'Habari za mchana,';

  @override
  String get greetingEvening => 'Habari za jioni,';

  @override
  String greetingName(String name) {
    return '$name! 👋';
  }

  @override
  String get searchProductsHint => 'Tafuta bidhaa...';

  @override
  String searchInCategoryHint(String category) {
    return 'Tafuta kwenye $category...';
  }

  @override
  String get actionBrowse => 'Angalia';

  @override
  String get actionShopNow => 'Nunua Sasa';

  @override
  String get actionViewAll => 'Ona zote';

  @override
  String get quickDeals => 'Ofa';

  @override
  String get quickNewArrivals => 'Bidhaa Mpya';

  @override
  String get quickBestSellers => 'Zinazouzwa Sana';

  @override
  String get trendingNow => 'Zinazovuma Sasa';

  @override
  String get allProducts => 'Bidhaa Zote';

  @override
  String get quickReorder => 'Agiza Tena';

  @override
  String get bannerTitle => 'BEI ZA JUMLA';

  @override
  String get bannerSubtitle => 'Nunua zaidi, okoa zaidi!';

  @override
  String get recentlyOrdered => 'Uliagiza Hivi Karibuni';

  @override
  String get chipAll => 'Zote';

  @override
  String get filterAction => 'Chuja';

  @override
  String get sortAction => 'Panga';

  @override
  String get priceFilter => 'Bei';

  @override
  String get moqFilter => 'MOQ';

  @override
  String get minPriceHint => 'Bei ya chini';

  @override
  String get maxPriceHint => 'Bei ya juu';

  @override
  String get minMoqHint => 'MOQ ya chini';

  @override
  String get maxMoqHint => 'MOQ ya juu';

  @override
  String get invalidFilterAmount => 'Weka namba sahihi.';

  @override
  String get invalidFilterRange =>
      'Kiasi cha chini kisiwe kikubwa kuliko cha juu.';

  @override
  String get sortPopular => 'Maarufu zaidi';

  @override
  String get sortNewest => 'Mpya zaidi';

  @override
  String get sortPriceLow => 'Bei ya chini kwanza';

  @override
  String get sortPriceHigh => 'Bei ya juu kwanza';

  @override
  String get priceUnder5000 => 'Chini ya TZS 5,000';

  @override
  String get price5000To10000 => 'TZS 5,000 – 10,000';

  @override
  String get priceOver10000 => 'Zaidi ya TZS 10,000';

  @override
  String get moqSingle => 'MOQ 1 tu';

  @override
  String get moqUpTo6 => 'MOQ hadi 6';

  @override
  String get moqUpTo12 => 'MOQ hadi 12';

  @override
  String get actionClearFilters => 'Futa vichujio';

  @override
  String get actionShowResults => 'Onyesha bidhaa';

  @override
  String get productsEmptyTitle => 'Hakuna bidhaa';

  @override
  String get productsEmptyMessage => 'Jaribu neno lingine au ondoa vichujio.';

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
  String get verifiedSeller => 'Muuzaji Aliyethibitishwa';

  @override
  String get badgeBestseller => 'Inauzwa Sana';

  @override
  String get badgeNew => 'Mpya';

  @override
  String get badgeDeal => 'Ofa';

  @override
  String get infoStock => 'Stock';

  @override
  String get infoDelivery => 'Uwasilishaji';

  @override
  String stockAtLeast(int count) {
    return '$count+ pcs';
  }

  @override
  String deliveryDays(int min, int max) {
    return 'siku $min–$max';
  }

  @override
  String get tiersTitle => 'Nunua zaidi, lipa kidogo';

  @override
  String tierRange(int min, int max) {
    return '$min–$max pcs';
  }

  @override
  String tierFrom(int min) {
    return '$min+ pcs';
  }

  @override
  String get quantityLabel => 'Kiasi';

  @override
  String savingsLabel(String amount) {
    return 'Unaokoa $amount';
  }

  @override
  String nextTierHint(int count, String price) {
    return 'Ongeza pcs $count upate $price kila moja';
  }

  @override
  String get actionAskSeller => 'Uliza Muuzaji';

  @override
  String get descriptionTitle => 'Maelezo';

  @override
  String get actionFavourite => 'Penda';

  @override
  String get actionShare => 'Shiriki';

  @override
  String get actionZoom => 'Kuza picha';

  @override
  String get actionIncrease => 'Ongeza';

  @override
  String get actionDecrease => 'Punguza';

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
  String get cartTitle => 'Kikapu Chako';

  @override
  String get actionEdit => 'Hariri';

  @override
  String get actionDone => 'Maliza';

  @override
  String get cartEmptyTitle => 'Kikapu chako ni tupu';

  @override
  String get cartEmptyMessage =>
      'Ongeza bidhaa uanze kuagiza kwa bei za jumla.';

  @override
  String get actionStartShopping => 'Anza kununua';

  @override
  String cartNudge(int count, String product, String price) {
    return 'Ongeza pcs $count za $product upate $price kila moja.';
  }

  @override
  String get wholesalePriceTag => 'Bei ya jumla';

  @override
  String cartTierLabel(int min, String price) {
    return '$min+ pcs @ $price';
  }

  @override
  String get moqMet => 'MOQ imetimia';

  @override
  String get actionRemove => 'Ondoa';

  @override
  String summaryItems(int count) {
    return 'Bidhaa ($count)';
  }

  @override
  String get summaryDelivery => 'Usafirishaji';

  @override
  String get summaryTotal => 'Jumla';

  @override
  String get summaryItemsTotal => 'Jumla ya Bidhaa';

  @override
  String get summaryAmountToPay => 'Jumla ya Kulipa';

  @override
  String get cartDeliveryNote =>
      'Gharama ya usafirishaji huongezwa kwenye malipo.';

  @override
  String get actionContinueToCheckout => 'Endelea kwenye Malipo';

  @override
  String get addedToCart => 'Imeongezwa kikapuni.';

  @override
  String get actionViewCart => 'Ona Kikapu';

  @override
  String quickAddTotal(String amount) {
    return 'Jumla: $amount';
  }

  @override
  String get errorMoqNotMet => 'Kiasi ni chini ya MOQ ya bidhaa hii.';

  @override
  String get errorOutOfStock => 'Stock haitoshi kwa kiasi hiki.';

  @override
  String get errorPriceChanged =>
      'Bei zimebadilika. Hakiki jumla mpya kisha uthibitishe tena.';

  @override
  String get checkoutTitle => 'Malipo na Usafirishaji';

  @override
  String get stepAddress => 'Anwani';

  @override
  String get stepDelivery => 'Usafirishaji';

  @override
  String get stepPayment => 'Malipo';

  @override
  String get stepReview => 'Hakiki';

  @override
  String get deliveryAddressTitle => 'Anwani ya Uwasilishaji';

  @override
  String get actionChange => 'Badilisha';

  @override
  String get actionAddAddress => 'Ongeza anwani';

  @override
  String get noAddressMessage => 'Ongeza anwani ya kupokelea oda yako.';

  @override
  String get chooseDeliveryTitle => 'Chagua Usafirishaji';

  @override
  String get deliveryTomorrow => 'kesho';

  @override
  String deliveryOption(String name, String eta) {
    return '$name ($eta)';
  }

  @override
  String get paymentMethodTitle => 'Njia ya Malipo';

  @override
  String get payAfterOrderingHint =>
      'Utaona namba ya kulipia baada ya kuthibitisha oda.';

  @override
  String payToTitle(String amount, String method) {
    return 'Lipa $amount kwa $method';
  }

  @override
  String get payToNumber => 'Lipa Namba / simu';

  @override
  String get payToBankAccount => 'Namba ya akaunti';

  @override
  String get payToAccountName => 'Jina la akaunti';

  @override
  String get payToBank => 'Benki';

  @override
  String get payToNoteHint => 'Andika hii kama maelezo / kumbukumbu ya malipo';

  @override
  String payBefore(String time) {
    return 'Lipa kabla ya $time, la sivyo oda itaghairiwa.';
  }

  @override
  String get actionCopy => 'Nakili';

  @override
  String get copiedMessage => 'Imenakiliwa.';

  @override
  String get actionIPaid => 'Nimelipa';

  @override
  String get actionChangePaymentMethod => 'Badilisha njia ya malipo';

  @override
  String get changePaymentMethodTitle => 'Badilisha njia ya malipo';

  @override
  String get changePaymentMethodMessage =>
      'Chagua njia nyingine. Muda wa kulipa hauanzi upya.';

  @override
  String paymentMethodChanged(String method) {
    return 'Sasa utalipa kwa $method.';
  }

  @override
  String get paymentMethodChangedToCash =>
      'Oda imethibitishwa. Utalipa ukipokea.';

  @override
  String get paymentUnderReviewTitle => 'Tunakagua malipo yako';

  @override
  String paymentUnderReviewMessage(String reference) {
    return 'Tutakujulisha tukishathibitisha. Namba ya muamala: $reference';
  }

  @override
  String get paymentRejectedTitle => 'Malipo hayakuthibitishwa';

  @override
  String get paymentRejectedMessage =>
      'Hatukuweza kuthibitisha malipo. Angalia taarifa na utume tena.';

  @override
  String get paymentSheetTitle => 'Thibitisha malipo';

  @override
  String get paymentSheetMessage =>
      'Weka taarifa zilizo kwenye SMS ya malipo. Tutazikagua kisha tuthibitishe oda.';

  @override
  String get payerPhoneLabel => 'Namba uliyolipia';

  @override
  String get payerBankLabel => 'Akaunti au jina ulilolipia';

  @override
  String get paymentReferenceLabel => 'Namba ya muamala (kwenye SMS)';

  @override
  String get paymentReferenceHint => 'mfano QJK3X7ABC1';

  @override
  String get actionSendPayment => 'Tuma';

  @override
  String get paymentSent => 'Tumepokea. Tunakagua malipo yako.';

  @override
  String get fieldRequired => 'Jaza sehemu hii.';

  @override
  String get actionContinueToReview => 'Endelea Kuhakiki';

  @override
  String get reviewTitle => 'Hakiki Oda';

  @override
  String get deliveryMethodTitle => 'Njia ya Usafirishaji';

  @override
  String get orderSummaryTitle => 'Muhtasari wa Oda';

  @override
  String get actionConfirmOrder => 'Thibitisha Oda';

  @override
  String get paymentSecure => 'Malipo yako ni salama.';

  @override
  String get orderReceivedTitle => 'Oda Imepokelewa!';

  @override
  String orderReceivedMessage(String name) {
    return 'Asante, $name. Tumeanza kuandaa oda yako.';
  }

  @override
  String orderNumber(String number) {
    return '#$number';
  }

  @override
  String get actionTrackOrder => 'Fuatilia Oda';

  @override
  String get actionBackHome => 'Rudi Nyumbani';

  @override
  String get addressFormTitle => 'Anwani Mpya';

  @override
  String get recipientNameLabel => 'Jina la mpokeaji';

  @override
  String get streetLabel => 'Mtaa / eneo';

  @override
  String get streetHint => 'Mfano: Kariakoo, Mtaa wa Lumumba';

  @override
  String get streetRequired => 'Andika mtaa au eneo.';

  @override
  String get landmarkLabel => 'Alama ya karibu';

  @override
  String get actionSaveAddress => 'Hifadhi anwani';

  @override
  String get chooseAddressTitle => 'Chagua anwani';

  @override
  String get ordersTitle => 'Oda Zangu';

  @override
  String get tabActiveOrders => 'Zinazoendelea';

  @override
  String get tabDeliveredOrders => 'Zimefika';

  @override
  String get ordersEmptyTitle => 'Hakuna oda hapa';

  @override
  String get ordersEmptyMessage => 'Oda zako zitaonekana hapa.';

  @override
  String get statusPendingPayment => 'Inasubiri malipo';

  @override
  String get statusConfirmed => 'Imethibitishwa';

  @override
  String get statusPacked => 'Imepakiwa';

  @override
  String get statusDispatched => 'Imetumwa';

  @override
  String get statusInTransit => 'Inasafirishwa';

  @override
  String get statusDelivered => 'Imewasili';

  @override
  String get statusCancelled => 'Imeghairiwa';

  @override
  String get statusExpired => 'Muda umeisha';

  @override
  String get trackingPendingPayment =>
      'Kamilisha malipo ili tuanze kuandaa oda yako.';

  @override
  String get trackingConfirmed => 'Tunaandaa oda yako.';

  @override
  String get trackingPacked => 'Oda yako iko tayari kutumwa.';

  @override
  String get trackingDispatched => 'Oda yako imekabidhiwa wakala.';

  @override
  String get trackingInTransitTitle => 'Njiani';

  @override
  String get trackingInTransit => 'Oda yako inakuja.';

  @override
  String get trackingDelivered => 'Asante kwa kununua CHIMBO!';

  @override
  String get trackingCancelled => 'Oda hii imeghairiwa.';

  @override
  String get trackingExpired => 'Muda wa malipo umeisha.';

  @override
  String get estimatedDeliveryTitle => 'Makadirio ya Uwasilishaji';

  @override
  String get deliveredOnTitle => 'Imefika tarehe';

  @override
  String get actionDownloadReceipt => 'Pakua Risiti';

  @override
  String get reorderDone => 'Bidhaa zimerudishwa kikapuni.';

  @override
  String get deliveryAgentTitle => 'Wakala wa Uwasilishaji';

  @override
  String get actionCall => 'Piga simu';

  @override
  String get actionMessage => 'Tuma ujumbe';

  @override
  String get actionCancelOrder => 'Ghairi oda';

  @override
  String get cancelOrderConfirmTitle => 'Ghairi oda hii?';

  @override
  String get cancelOrderConfirmMessage =>
      'Oda itaghairiwa na bidhaa kurudishwa stock. Huwezi kutendua hili.';

  @override
  String get orderCancelledMessage => 'Oda imeghairiwa.';

  @override
  String orderItemLine(int quantity, String price) {
    return '$quantity × $price';
  }

  @override
  String get savedToWishlist => 'Imehifadhiwa kwenye vipendwa.';

  @override
  String get actionUnfavourite => 'Ondoa kwenye vipendwa';

  @override
  String discountPercent(int percent) {
    return '-$percent%';
  }

  @override
  String get menuWishlist => 'Vipendwa';

  @override
  String get menuWishlistHint => 'Bidhaa ulizohifadhi';

  @override
  String get wishlistEmptyTitle => 'Hakuna vipendwa bado';

  @override
  String get wishlistEmptyMessage =>
      'Gusa ♡ kwenye bidhaa ili kuihifadhi hapa.';

  @override
  String get outOfStock => 'Imeisha';

  @override
  String get actionOutOfStock => 'Imeisha stock';

  @override
  String otpTestModeHint(String code) {
    return 'Hali ya majaribio: namba ni $code';
  }

  @override
  String cartProblemNotEnoughStock(int count) {
    return 'Stock haitoshi — zimebaki $count';
  }

  @override
  String cartProblemBelowMoq(int moq) {
    return 'Chini ya MOQ ($moq)';
  }

  @override
  String cartFixLowerTo(int count) {
    return 'Punguza hadi $count';
  }

  @override
  String cartFixRaiseTo(int count) {
    return 'Ongeza hadi $count';
  }

  @override
  String get cartCannotCheckout =>
      'Rekebisha bidhaa zilizowekwa alama nyekundu ili kuendelea.';

  @override
  String get summarySavings => 'Unaokoa';
}
