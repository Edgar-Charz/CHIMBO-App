import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sw'),
  ];

  /// App name shown in the task switcher.
  ///
  /// In sw, this message translates to:
  /// **'CHIMBO'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In sw, this message translates to:
  /// **'Nyumbani'**
  String get navHome;

  /// No description provided for @navDiscover.
  ///
  /// In sw, this message translates to:
  /// **'Gundua'**
  String get navDiscover;

  /// No description provided for @navCart.
  ///
  /// In sw, this message translates to:
  /// **'Kikapu'**
  String get navCart;

  /// No description provided for @navOrders.
  ///
  /// In sw, this message translates to:
  /// **'Oda'**
  String get navOrders;

  /// No description provided for @navProfile.
  ///
  /// In sw, this message translates to:
  /// **'Wasifu'**
  String get navProfile;

  /// No description provided for @comingSoonTitle.
  ///
  /// In sw, this message translates to:
  /// **'Inakuja hivi karibuni'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonMessage.
  ///
  /// In sw, this message translates to:
  /// **'Sehemu hii itakuwa tayari hivi punde.'**
  String get comingSoonMessage;

  /// No description provided for @pressBackAgainToExit.
  ///
  /// In sw, this message translates to:
  /// **'Bonyeza nyuma tena ili kutoka.'**
  String get pressBackAgainToExit;

  /// No description provided for @actionContinue.
  ///
  /// In sw, this message translates to:
  /// **'Endelea'**
  String get actionContinue;

  /// No description provided for @actionAddToCart.
  ///
  /// In sw, this message translates to:
  /// **'Ongeza Kikapuni'**
  String get actionAddToCart;

  /// No description provided for @actionRetry.
  ///
  /// In sw, this message translates to:
  /// **'Jaribu tena'**
  String get actionRetry;

  /// No description provided for @phoneLabel.
  ///
  /// In sw, this message translates to:
  /// **'Namba ya simu'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In sw, this message translates to:
  /// **'7XX XXX XXX'**
  String get phoneHint;

  /// Lowest tier price on a product card, e.g. 'kuanzia TZS 4,400'.
  ///
  /// In sw, this message translates to:
  /// **'kuanzia {price}'**
  String priceFrom(String price);

  /// No description provided for @verifiedBusiness.
  ///
  /// In sw, this message translates to:
  /// **'Imethibitishwa'**
  String get verifiedBusiness;

  /// No description provided for @errorNetwork.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna mtandao. Angalia intaneti yako kisha ujaribu tena.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In sw, this message translates to:
  /// **'Mtandao uko polepole. Tafadhali jaribu tena.'**
  String get errorTimeout;

  /// No description provided for @errorUnknown.
  ///
  /// In sw, this message translates to:
  /// **'Kuna tatizo limetokea. Tafadhali jaribu tena.'**
  String get errorUnknown;

  /// No description provided for @debugOpenTools.
  ///
  /// In sw, this message translates to:
  /// **'Zana za wasanidi'**
  String get debugOpenTools;

  /// No description provided for @debugTitle.
  ///
  /// In sw, this message translates to:
  /// **'Zana za wasanidi'**
  String get debugTitle;

  /// No description provided for @debugServerSection.
  ///
  /// In sw, this message translates to:
  /// **'Seva'**
  String get debugServerSection;

  /// No description provided for @debugApiAddress.
  ///
  /// In sw, this message translates to:
  /// **'Anwani ya API'**
  String get debugApiAddress;

  /// No description provided for @debugServerStatus.
  ///
  /// In sw, this message translates to:
  /// **'Hali ya seva'**
  String get debugServerStatus;

  /// No description provided for @debugDatabaseStatus.
  ///
  /// In sw, this message translates to:
  /// **'Hifadhidata'**
  String get debugDatabaseStatus;

  /// No description provided for @debugApiVersion.
  ///
  /// In sw, this message translates to:
  /// **'Toleo la API'**
  String get debugApiVersion;

  /// No description provided for @debugServerTime.
  ///
  /// In sw, this message translates to:
  /// **'Muda wa seva'**
  String get debugServerTime;

  /// No description provided for @debugStatusOk.
  ///
  /// In sw, this message translates to:
  /// **'Iko sawa'**
  String get debugStatusOk;

  /// No description provided for @debugStatusProblem.
  ///
  /// In sw, this message translates to:
  /// **'Ina tatizo'**
  String get debugStatusProblem;

  /// No description provided for @debugUiKitSection.
  ///
  /// In sw, this message translates to:
  /// **'Vipengele vya muonekano'**
  String get debugUiKitSection;

  /// No description provided for @brandTaglineQuality.
  ///
  /// In sw, this message translates to:
  /// **'BIDHAA BORA'**
  String get brandTaglineQuality;

  /// No description provided for @brandTaglinePrice.
  ///
  /// In sw, this message translates to:
  /// **'BEI NAFUU'**
  String get brandTaglinePrice;

  /// No description provided for @brandTaglineBusiness.
  ///
  /// In sw, this message translates to:
  /// **'BIASHARA IMARA'**
  String get brandTaglineBusiness;

  /// No description provided for @sloganOrder.
  ///
  /// In sw, this message translates to:
  /// **'Agiza.'**
  String get sloganOrder;

  /// No description provided for @sloganTrust.
  ///
  /// In sw, this message translates to:
  /// **'Amini.'**
  String get sloganTrust;

  /// No description provided for @sloganReceive.
  ///
  /// In sw, this message translates to:
  /// **'Pokea.'**
  String get sloganReceive;

  /// No description provided for @sloganGrow.
  ///
  /// In sw, this message translates to:
  /// **'Kuza Biashara.'**
  String get sloganGrow;

  /// No description provided for @categoryJewelry.
  ///
  /// In sw, this message translates to:
  /// **'Jewelry'**
  String get categoryJewelry;

  /// No description provided for @categoryCosmetics.
  ///
  /// In sw, this message translates to:
  /// **'Cosmetics'**
  String get categoryCosmetics;

  /// No description provided for @actionGetStarted.
  ///
  /// In sw, this message translates to:
  /// **'Anza Sasa'**
  String get actionGetStarted;

  /// No description provided for @onboardingProductsTitle.
  ///
  /// In sw, this message translates to:
  /// **'Bidhaa za Biashara Yako'**
  String get onboardingProductsTitle;

  /// No description provided for @onboardingProductsSubtitle.
  ///
  /// In sw, this message translates to:
  /// **'Jewelry na Cosmetics — zote sehemu moja.'**
  String get onboardingProductsSubtitle;

  /// No description provided for @onboardingWholesaleTitle.
  ///
  /// In sw, this message translates to:
  /// **'Bei za Jumla Zinazokulipa'**
  String get onboardingWholesaleTitle;

  /// No description provided for @onboardingWholesaleSubtitle.
  ///
  /// In sw, this message translates to:
  /// **'Nunua zaidi. Okoa zaidi. Pata faida zaidi.'**
  String get onboardingWholesaleSubtitle;

  /// No description provided for @onboardingSaveMore.
  ///
  /// In sw, this message translates to:
  /// **'OKOA ZAIDI'**
  String get onboardingSaveMore;

  /// No description provided for @onboardingDeliveryTitle.
  ///
  /// In sw, this message translates to:
  /// **'Agiza kwa Urahisi. Pokea Haraka.'**
  String get onboardingDeliveryTitle;

  /// No description provided for @onboardingStepChoose.
  ///
  /// In sw, this message translates to:
  /// **'Chagua'**
  String get onboardingStepChoose;

  /// No description provided for @onboardingStepPay.
  ///
  /// In sw, this message translates to:
  /// **'Lipa'**
  String get onboardingStepPay;

  /// No description provided for @onboardingStepReceive.
  ///
  /// In sw, this message translates to:
  /// **'Pokea'**
  String get onboardingStepReceive;

  /// No description provided for @onboardingDeliveryPromise.
  ///
  /// In sw, this message translates to:
  /// **'Tunafikisha oda yako salama na kwa wakati.'**
  String get onboardingDeliveryPromise;

  /// Screen-reader label for the slide dots.
  ///
  /// In sw, this message translates to:
  /// **'Ukurasa {current} kati ya {total}'**
  String onboardingPageIndicator(int current, int total);

  /// Progress label above a multi-step form.
  ///
  /// In sw, this message translates to:
  /// **'Hatua {current} kati ya {total}'**
  String stepProgress(int current, int total);

  /// No description provided for @actionBack.
  ///
  /// In sw, this message translates to:
  /// **'Rudi'**
  String get actionBack;

  /// No description provided for @actionLogout.
  ///
  /// In sw, this message translates to:
  /// **'Toka'**
  String get actionLogout;

  /// No description provided for @optionalField.
  ///
  /// In sw, this message translates to:
  /// **'Si lazima'**
  String get optionalField;

  /// No description provided for @phoneTitle.
  ///
  /// In sw, this message translates to:
  /// **'Karibu CHIMBO'**
  String get phoneTitle;

  /// No description provided for @phoneSubtitle.
  ///
  /// In sw, this message translates to:
  /// **'Anza kwa namba yako ya simu.'**
  String get phoneSubtitle;

  /// No description provided for @phoneHelper.
  ///
  /// In sw, this message translates to:
  /// **'Tutaitumia kuthibitisha akaunti na kukufikishia oda.'**
  String get phoneHelper;

  /// No description provided for @phoneInvalid.
  ///
  /// In sw, this message translates to:
  /// **'Weka namba sahihi ya simu, mfano 712 345 678.'**
  String get phoneInvalid;

  /// No description provided for @termsNoticeStart.
  ///
  /// In sw, this message translates to:
  /// **'Kwa kuendelea, unakubali'**
  String get termsNoticeStart;

  /// No description provided for @termsLink.
  ///
  /// In sw, this message translates to:
  /// **'Masharti'**
  String get termsLink;

  /// No description provided for @termsNoticeAnd.
  ///
  /// In sw, this message translates to:
  /// **'na'**
  String get termsNoticeAnd;

  /// No description provided for @privacyLink.
  ///
  /// In sw, this message translates to:
  /// **'Sera ya Faragha'**
  String get privacyLink;

  /// No description provided for @otpTitle.
  ///
  /// In sw, this message translates to:
  /// **'Thibitisha Namba'**
  String get otpTitle;

  /// No description provided for @otpSentTo.
  ///
  /// In sw, this message translates to:
  /// **'Tumeweka namba ya uthibitisho kwenye'**
  String get otpSentTo;

  /// Screen-reader label for the code boxes.
  ///
  /// In sw, this message translates to:
  /// **'Namba ya uthibitisho ya tarakimu {length}'**
  String otpFieldLabel(int length);

  /// No description provided for @actionVerify.
  ///
  /// In sw, this message translates to:
  /// **'Thibitisha'**
  String get actionVerify;

  /// No description provided for @otpNotReceived.
  ///
  /// In sw, this message translates to:
  /// **'Hukupokea namba?'**
  String get otpNotReceived;

  /// No description provided for @otpResend.
  ///
  /// In sw, this message translates to:
  /// **'Tuma tena'**
  String get otpResend;

  /// Resend link while the wait timer runs.
  ///
  /// In sw, this message translates to:
  /// **'Tuma tena baada ya {seconds}s'**
  String otpResendIn(int seconds);

  /// No description provided for @otpResent.
  ///
  /// In sw, this message translates to:
  /// **'Tumetuma namba mpya ya uthibitisho.'**
  String get otpResent;

  /// No description provided for @otpChangeNumber.
  ///
  /// In sw, this message translates to:
  /// **'Badilisha namba'**
  String get otpChangeNumber;

  /// No description provided for @otpIncomplete.
  ///
  /// In sw, this message translates to:
  /// **'Weka tarakimu zote {length}.'**
  String otpIncomplete(int length);

  /// No description provided for @otpInvalid.
  ///
  /// In sw, this message translates to:
  /// **'Namba ya uthibitisho si sahihi. Jaribu tena.'**
  String get otpInvalid;

  /// No description provided for @pinLoginTitle.
  ///
  /// In sw, this message translates to:
  /// **'Ingia kwa PIN'**
  String get pinLoginTitle;

  /// No description provided for @pinLoginSubtitle.
  ///
  /// In sw, this message translates to:
  /// **'Weka PIN ya akaunti ya'**
  String get pinLoginSubtitle;

  /// No description provided for @actionLogin.
  ///
  /// In sw, this message translates to:
  /// **'Ingia'**
  String get actionLogin;

  /// No description provided for @pinForgot.
  ///
  /// In sw, this message translates to:
  /// **'Umesahau PIN?'**
  String get pinForgot;

  /// No description provided for @pinLockedMessage.
  ///
  /// In sw, this message translates to:
  /// **'PIN imefungwa baada ya majaribio 5 yasiyo sahihi. Tutakutumia namba kwa SMS ili uweke PIN mpya.'**
  String get pinLockedMessage;

  /// No description provided for @createPinTitle.
  ///
  /// In sw, this message translates to:
  /// **'Tengeneza PIN'**
  String get createPinTitle;

  /// No description provided for @resetPinTitle.
  ///
  /// In sw, this message translates to:
  /// **'Weka PIN Mpya'**
  String get resetPinTitle;

  /// No description provided for @createPinSubtitle.
  ///
  /// In sw, this message translates to:
  /// **'Utaitumia kuingia CHIMBO kila mara. Usimwambie mtu yeyote.'**
  String get createPinSubtitle;

  /// No description provided for @pinStepCurrent.
  ///
  /// In sw, this message translates to:
  /// **'Weka PIN yako ya sasa'**
  String get pinStepCurrent;

  /// No description provided for @pinStepNew.
  ///
  /// In sw, this message translates to:
  /// **'Chagua PIN ya tarakimu 4 hadi 6'**
  String get pinStepNew;

  /// No description provided for @pinStepConfirm.
  ///
  /// In sw, this message translates to:
  /// **'Rudia PIN ili kuthibitisha'**
  String get pinStepConfirm;

  /// No description provided for @pinWrongLength.
  ///
  /// In sw, this message translates to:
  /// **'PIN iwe tarakimu 4 hadi 6.'**
  String get pinWrongLength;

  /// No description provided for @pinMismatch.
  ///
  /// In sw, this message translates to:
  /// **'PIN hazilingani. Rudia tena.'**
  String get pinMismatch;

  /// No description provided for @pinStartOver.
  ///
  /// In sw, this message translates to:
  /// **'Anza upya'**
  String get pinStartOver;

  /// No description provided for @actionSavePin.
  ///
  /// In sw, this message translates to:
  /// **'Hifadhi PIN'**
  String get actionSavePin;

  /// No description provided for @menuChangePin.
  ///
  /// In sw, this message translates to:
  /// **'Badilisha PIN'**
  String get menuChangePin;

  /// No description provided for @menuChangePinHint.
  ///
  /// In sw, this message translates to:
  /// **'Linda akaunti yako'**
  String get menuChangePinHint;

  /// No description provided for @changePinNotice.
  ///
  /// In sw, this message translates to:
  /// **'Ukibadilisha PIN, simu nyingine zote zilizoingia kwenye akaunti yako zitatolewa.'**
  String get changePinNotice;

  /// No description provided for @pinChanged.
  ///
  /// In sw, this message translates to:
  /// **'PIN imebadilishwa.'**
  String get pinChanged;

  /// No description provided for @signedOutNotice.
  ///
  /// In sw, this message translates to:
  /// **'Umetolewa kwenye akaunti. Tafadhali ingia tena.'**
  String get signedOutNotice;

  /// Screen-reader label for the PIN dots.
  ///
  /// In sw, this message translates to:
  /// **'PIN: tarakimu {count} zimewekwa'**
  String pinDotsLabel(int count);

  /// No description provided for @businessTitle.
  ///
  /// In sw, this message translates to:
  /// **'Tuambie Kuhusu Biashara Yako'**
  String get businessTitle;

  /// No description provided for @businessSubtitle.
  ///
  /// In sw, this message translates to:
  /// **'Taarifa chache tu, kisha unaanza.'**
  String get businessSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In sw, this message translates to:
  /// **'Jina kamili'**
  String get fullNameLabel;

  /// No description provided for @fullNameRequired.
  ///
  /// In sw, this message translates to:
  /// **'Andika jina lako kamili.'**
  String get fullNameRequired;

  /// No description provided for @businessNameLabel.
  ///
  /// In sw, this message translates to:
  /// **'Jina la biashara / duka'**
  String get businessNameLabel;

  /// No description provided for @regionLabel.
  ///
  /// In sw, this message translates to:
  /// **'Mkoa'**
  String get regionLabel;

  /// No description provided for @regionHint.
  ///
  /// In sw, this message translates to:
  /// **'Chagua mkoa'**
  String get regionHint;

  /// No description provided for @regionRequired.
  ///
  /// In sw, this message translates to:
  /// **'Chagua mkoa wako.'**
  String get regionRequired;

  /// No description provided for @districtLabel.
  ///
  /// In sw, this message translates to:
  /// **'Wilaya'**
  String get districtLabel;

  /// No description provided for @locationsLoadFailed.
  ///
  /// In sw, this message translates to:
  /// **'Imeshindikana kupakia orodha. Gusa kujaribu tena.'**
  String get locationsLoadFailed;

  /// No description provided for @locationSearchHint.
  ///
  /// In sw, this message translates to:
  /// **'Tafuta kwa jina...'**
  String get locationSearchHint;

  /// No description provided for @locationNoResults.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna eneo linalolingana na utafutaji wako.'**
  String get locationNoResults;

  /// No description provided for @actionEnterChimbo.
  ///
  /// In sw, this message translates to:
  /// **'Ingia CHIMBO'**
  String get actionEnterChimbo;

  /// No description provided for @businessEditLater.
  ///
  /// In sw, this message translates to:
  /// **'Unaweza kubadilisha taarifa hizi baadaye.'**
  String get businessEditLater;

  /// No description provided for @actionCancel.
  ///
  /// In sw, this message translates to:
  /// **'Ghairi'**
  String get actionCancel;

  /// No description provided for @actionSave.
  ///
  /// In sw, this message translates to:
  /// **'Hifadhi'**
  String get actionSave;

  /// No description provided for @actionDelete.
  ///
  /// In sw, this message translates to:
  /// **'Futa'**
  String get actionDelete;

  /// No description provided for @comingSoonShort.
  ///
  /// In sw, this message translates to:
  /// **'Inakuja'**
  String get comingSoonShort;

  /// No description provided for @profileEdit.
  ///
  /// In sw, this message translates to:
  /// **'Hariri Wasifu'**
  String get profileEdit;

  /// No description provided for @profileBusinessOwner.
  ///
  /// In sw, this message translates to:
  /// **'Mmiliki wa Biashara'**
  String get profileBusinessOwner;

  /// No description provided for @profileEditPhoto.
  ///
  /// In sw, this message translates to:
  /// **'Badilisha picha'**
  String get profileEditPhoto;

  /// No description provided for @menuBusinessInfo.
  ///
  /// In sw, this message translates to:
  /// **'Taarifa za Biashara'**
  String get menuBusinessInfo;

  /// No description provided for @menuBusinessInfoHint.
  ///
  /// In sw, this message translates to:
  /// **'Jina la duka na mawasiliano'**
  String get menuBusinessInfoHint;

  /// No description provided for @menuAddresses.
  ///
  /// In sw, this message translates to:
  /// **'Anwani za Usafirishaji'**
  String get menuAddresses;

  /// No description provided for @menuAddressesHint.
  ///
  /// In sw, this message translates to:
  /// **'Mahali pa kupokea oda'**
  String get menuAddressesHint;

  /// No description provided for @menuPayments.
  ///
  /// In sw, this message translates to:
  /// **'Malipo yangu'**
  String get menuPayments;

  /// No description provided for @menuPaymentsHint.
  ///
  /// In sw, this message translates to:
  /// **'Historia ya malipo na njia tunazokubali'**
  String get menuPaymentsHint;

  /// No description provided for @myPaymentsTabHistory.
  ///
  /// In sw, this message translates to:
  /// **'Historia'**
  String get myPaymentsTabHistory;

  /// No description provided for @myPaymentsTabMethods.
  ///
  /// In sw, this message translates to:
  /// **'Njia za malipo'**
  String get myPaymentsTabMethods;

  /// No description provided for @myPaymentsEmpty.
  ///
  /// In sw, this message translates to:
  /// **'Bado hujafanya malipo. Malipo ya oda zako yataonekana hapa.'**
  String get myPaymentsEmpty;

  /// No description provided for @acceptedMethodsTitle.
  ///
  /// In sw, this message translates to:
  /// **'Njia za malipo tunazokubali'**
  String get acceptedMethodsTitle;

  /// No description provided for @acceptedMethodsCash.
  ///
  /// In sw, this message translates to:
  /// **'Lipa kwa pesa taslimu unapopokea mzigo.'**
  String get acceptedMethodsCash;

  /// No description provided for @paymentStatusSubmitted.
  ///
  /// In sw, this message translates to:
  /// **'Inakaguliwa'**
  String get paymentStatusSubmitted;

  /// No description provided for @paymentStatusConfirmed.
  ///
  /// In sw, this message translates to:
  /// **'Imethibitishwa'**
  String get paymentStatusConfirmed;

  /// No description provided for @paymentStatusRejected.
  ///
  /// In sw, this message translates to:
  /// **'Imekataliwa'**
  String get paymentStatusRejected;

  /// No description provided for @paymentOrderLine.
  ///
  /// In sw, this message translates to:
  /// **'Oda #{number} · {date}'**
  String paymentOrderLine(String number, String date);

  /// No description provided for @paymentReferenceLine.
  ///
  /// In sw, this message translates to:
  /// **'Namba ya muamala: {reference}'**
  String paymentReferenceLine(String reference);

  /// No description provided for @menuReceipts.
  ///
  /// In sw, this message translates to:
  /// **'Risiti na Historia'**
  String get menuReceipts;

  /// No description provided for @menuReceiptsHint.
  ///
  /// In sw, this message translates to:
  /// **'Ona oda na risiti zako'**
  String get menuReceiptsHint;

  /// No description provided for @menuNotifications.
  ///
  /// In sw, this message translates to:
  /// **'Arifa'**
  String get menuNotifications;

  /// No description provided for @menuNotificationsHint.
  ///
  /// In sw, this message translates to:
  /// **'Taarifa za oda na malipo'**
  String get menuNotificationsHint;

  /// No description provided for @notificationsTitle.
  ///
  /// In sw, this message translates to:
  /// **'Arifa'**
  String get notificationsTitle;

  /// No description provided for @actionMarkAllRead.
  ///
  /// In sw, this message translates to:
  /// **'Soma zote'**
  String get actionMarkAllRead;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna arifa bado'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyMessage.
  ///
  /// In sw, this message translates to:
  /// **'Tutakujulisha hapa hali ya oda yako ikibadilika.'**
  String get notificationsEmptyMessage;

  /// No description provided for @profilePhotoTitle.
  ///
  /// In sw, this message translates to:
  /// **'Picha ya wasifu'**
  String get profilePhotoTitle;

  /// No description provided for @actionChangePhoto.
  ///
  /// In sw, this message translates to:
  /// **'Badilisha picha'**
  String get actionChangePhoto;

  /// No description provided for @actionChoosePhoto.
  ///
  /// In sw, this message translates to:
  /// **'Chagua picha'**
  String get actionChoosePhoto;

  /// No description provided for @actionTakePhoto.
  ///
  /// In sw, this message translates to:
  /// **'Piga picha'**
  String get actionTakePhoto;

  /// No description provided for @actionRemovePhoto.
  ///
  /// In sw, this message translates to:
  /// **'Ondoa picha'**
  String get actionRemovePhoto;

  /// No description provided for @profilePhotoUploading.
  ///
  /// In sw, this message translates to:
  /// **'Inapakia picha…'**
  String get profilePhotoUploading;

  /// No description provided for @profilePhotoSaved.
  ///
  /// In sw, this message translates to:
  /// **'Picha imehifadhiwa.'**
  String get profilePhotoSaved;

  /// No description provided for @profilePhotoRemoved.
  ///
  /// In sw, this message translates to:
  /// **'Picha imeondolewa.'**
  String get profilePhotoRemoved;

  /// No description provided for @receiptDownloading.
  ///
  /// In sw, this message translates to:
  /// **'Inapakua risiti…'**
  String get receiptDownloading;

  /// No description provided for @menuHelp.
  ///
  /// In sw, this message translates to:
  /// **'Msaada'**
  String get menuHelp;

  /// No description provided for @menuHelpHint.
  ///
  /// In sw, this message translates to:
  /// **'Piga simu au pata maelekezo'**
  String get menuHelpHint;

  /// No description provided for @menuTerms.
  ///
  /// In sw, this message translates to:
  /// **'Vigezo na Masharti'**
  String get menuTerms;

  /// No description provided for @menuTermsHint.
  ///
  /// In sw, this message translates to:
  /// **'Masharti ya kutumia CHIMBO'**
  String get menuTermsHint;

  /// No description provided for @menuPrivacy.
  ///
  /// In sw, this message translates to:
  /// **'Sera ya Faragha'**
  String get menuPrivacy;

  /// No description provided for @menuPrivacyHint.
  ///
  /// In sw, this message translates to:
  /// **'Jinsi tunavyolinda taarifa zako'**
  String get menuPrivacyHint;

  /// No description provided for @helpIntro.
  ///
  /// In sw, this message translates to:
  /// **'Una swali kuhusu oda, malipo au akaunti yako? Tuko tayari kukusaidia.'**
  String get helpIntro;

  /// No description provided for @helpHoursTitle.
  ///
  /// In sw, this message translates to:
  /// **'Saa za huduma'**
  String get helpHoursTitle;

  /// No description provided for @helpCall.
  ///
  /// In sw, this message translates to:
  /// **'Piga simu {phone}'**
  String helpCall(String phone);

  /// No description provided for @helpWhatsapp.
  ///
  /// In sw, this message translates to:
  /// **'Tuma ujumbe WhatsApp'**
  String get helpWhatsapp;

  /// No description provided for @helpCannotOpen.
  ///
  /// In sw, this message translates to:
  /// **'Simu hii haina programu ya kufungua hiki.'**
  String get helpCannotOpen;

  /// No description provided for @legalUpdatedOn.
  ///
  /// In sw, this message translates to:
  /// **'Imesasishwa {date}'**
  String legalUpdatedOn(String date);

  /// No description provided for @menuSettings.
  ///
  /// In sw, this message translates to:
  /// **'Mipangilio'**
  String get menuSettings;

  /// No description provided for @menuSettingsHint.
  ///
  /// In sw, this message translates to:
  /// **'Lugha na usalama'**
  String get menuSettingsHint;

  /// No description provided for @logoutAccount.
  ///
  /// In sw, this message translates to:
  /// **'Toka kwenye Akaunti'**
  String get logoutAccount;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In sw, this message translates to:
  /// **'Toka kwenye akaunti?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In sw, this message translates to:
  /// **'Utahitaji namba yako ya simu kuingia tena.'**
  String get logoutConfirmMessage;

  /// No description provided for @profileSaved.
  ///
  /// In sw, this message translates to:
  /// **'Taarifa zimehifadhiwa.'**
  String get profileSaved;

  /// No description provided for @settingsLanguage.
  ///
  /// In sw, this message translates to:
  /// **'Lugha'**
  String get settingsLanguage;

  /// No description provided for @languageSwahili.
  ///
  /// In sw, this message translates to:
  /// **'Kiswahili'**
  String get languageSwahili;

  /// No description provided for @languageEnglish.
  ///
  /// In sw, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @settingsAccount.
  ///
  /// In sw, this message translates to:
  /// **'Akaunti'**
  String get settingsAccount;

  /// No description provided for @deleteAccount.
  ///
  /// In sw, this message translates to:
  /// **'Futa akaunti'**
  String get deleteAccount;

  /// No description provided for @deleteAccountHint.
  ///
  /// In sw, this message translates to:
  /// **'Taarifa zako binafsi zitafutwa'**
  String get deleteAccountHint;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In sw, this message translates to:
  /// **'Futa akaunti yako?'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmMessage.
  ///
  /// In sw, this message translates to:
  /// **'Hatua hii haiwezi kurudishwa. Taarifa zako binafsi zitafutwa; rekodi za oda zinabaki kwa ajili ya hesabu.'**
  String get deleteAccountConfirmMessage;

  /// No description provided for @greetingMorning.
  ///
  /// In sw, this message translates to:
  /// **'Habari za asubuhi,'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In sw, this message translates to:
  /// **'Habari za mchana,'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In sw, this message translates to:
  /// **'Habari za jioni,'**
  String get greetingEvening;

  /// No description provided for @greetingName.
  ///
  /// In sw, this message translates to:
  /// **'{name}! 👋'**
  String greetingName(String name);

  /// No description provided for @searchProductsHint.
  ///
  /// In sw, this message translates to:
  /// **'Tafuta bidhaa...'**
  String get searchProductsHint;

  /// No description provided for @searchInCategoryHint.
  ///
  /// In sw, this message translates to:
  /// **'Tafuta kwenye {category}...'**
  String searchInCategoryHint(String category);

  /// No description provided for @actionBrowse.
  ///
  /// In sw, this message translates to:
  /// **'Angalia'**
  String get actionBrowse;

  /// No description provided for @actionShopNow.
  ///
  /// In sw, this message translates to:
  /// **'Nunua Sasa'**
  String get actionShopNow;

  /// No description provided for @actionViewAll.
  ///
  /// In sw, this message translates to:
  /// **'Ona zote'**
  String get actionViewAll;

  /// No description provided for @quickDeals.
  ///
  /// In sw, this message translates to:
  /// **'Ofa'**
  String get quickDeals;

  /// No description provided for @timedOffersTitle.
  ///
  /// In sw, this message translates to:
  /// **'Ofa za muda'**
  String get timedOffersTitle;

  /// No description provided for @offerPercentLabel.
  ///
  /// In sw, this message translates to:
  /// **'Ofa −{percent}%'**
  String offerPercentLabel(int percent);

  /// No description provided for @offerEndsIn.
  ///
  /// In sw, this message translates to:
  /// **'Inaisha baada ya {time}'**
  String offerEndsIn(String time);

  /// No description provided for @quickNewArrivals.
  ///
  /// In sw, this message translates to:
  /// **'Bidhaa Mpya'**
  String get quickNewArrivals;

  /// No description provided for @quickBestSellers.
  ///
  /// In sw, this message translates to:
  /// **'Zinazouzwa Sana'**
  String get quickBestSellers;

  /// No description provided for @trendingNow.
  ///
  /// In sw, this message translates to:
  /// **'Zinazovuma Sasa'**
  String get trendingNow;

  /// No description provided for @allProducts.
  ///
  /// In sw, this message translates to:
  /// **'Bidhaa Zote'**
  String get allProducts;

  /// No description provided for @quickReorder.
  ///
  /// In sw, this message translates to:
  /// **'Agiza Tena'**
  String get quickReorder;

  /// No description provided for @bannerTitle.
  ///
  /// In sw, this message translates to:
  /// **'BEI ZA JUMLA'**
  String get bannerTitle;

  /// No description provided for @bannerSubtitle.
  ///
  /// In sw, this message translates to:
  /// **'Nunua zaidi, okoa zaidi!'**
  String get bannerSubtitle;

  /// No description provided for @recentlyOrdered.
  ///
  /// In sw, this message translates to:
  /// **'Uliagiza Hivi Karibuni'**
  String get recentlyOrdered;

  /// No description provided for @chipAll.
  ///
  /// In sw, this message translates to:
  /// **'Zote'**
  String get chipAll;

  /// No description provided for @filterAction.
  ///
  /// In sw, this message translates to:
  /// **'Chuja'**
  String get filterAction;

  /// No description provided for @sortAction.
  ///
  /// In sw, this message translates to:
  /// **'Panga'**
  String get sortAction;

  /// No description provided for @priceFilter.
  ///
  /// In sw, this message translates to:
  /// **'Bei'**
  String get priceFilter;

  /// No description provided for @moqFilter.
  ///
  /// In sw, this message translates to:
  /// **'MOQ'**
  String get moqFilter;

  /// No description provided for @minPriceHint.
  ///
  /// In sw, this message translates to:
  /// **'Bei ya chini'**
  String get minPriceHint;

  /// No description provided for @maxPriceHint.
  ///
  /// In sw, this message translates to:
  /// **'Bei ya juu'**
  String get maxPriceHint;

  /// No description provided for @minMoqHint.
  ///
  /// In sw, this message translates to:
  /// **'MOQ ya chini'**
  String get minMoqHint;

  /// No description provided for @maxMoqHint.
  ///
  /// In sw, this message translates to:
  /// **'MOQ ya juu'**
  String get maxMoqHint;

  /// No description provided for @invalidFilterAmount.
  ///
  /// In sw, this message translates to:
  /// **'Weka namba sahihi.'**
  String get invalidFilterAmount;

  /// No description provided for @invalidFilterRange.
  ///
  /// In sw, this message translates to:
  /// **'Kiasi cha chini kisiwe kikubwa kuliko cha juu.'**
  String get invalidFilterRange;

  /// No description provided for @sortPopular.
  ///
  /// In sw, this message translates to:
  /// **'Maarufu zaidi'**
  String get sortPopular;

  /// No description provided for @sortNewest.
  ///
  /// In sw, this message translates to:
  /// **'Mpya zaidi'**
  String get sortNewest;

  /// No description provided for @sortPriceLow.
  ///
  /// In sw, this message translates to:
  /// **'Bei ya chini kwanza'**
  String get sortPriceLow;

  /// No description provided for @sortPriceHigh.
  ///
  /// In sw, this message translates to:
  /// **'Bei ya juu kwanza'**
  String get sortPriceHigh;

  /// No description provided for @priceUnder5000.
  ///
  /// In sw, this message translates to:
  /// **'Chini ya TZS 5,000'**
  String get priceUnder5000;

  /// No description provided for @price5000To10000.
  ///
  /// In sw, this message translates to:
  /// **'TZS 5,000 – 10,000'**
  String get price5000To10000;

  /// No description provided for @priceOver10000.
  ///
  /// In sw, this message translates to:
  /// **'Zaidi ya TZS 10,000'**
  String get priceOver10000;

  /// No description provided for @moqSingle.
  ///
  /// In sw, this message translates to:
  /// **'MOQ 1 tu'**
  String get moqSingle;

  /// No description provided for @moqUpTo6.
  ///
  /// In sw, this message translates to:
  /// **'MOQ hadi 6'**
  String get moqUpTo6;

  /// No description provided for @moqUpTo12.
  ///
  /// In sw, this message translates to:
  /// **'MOQ hadi 12'**
  String get moqUpTo12;

  /// No description provided for @actionClearFilters.
  ///
  /// In sw, this message translates to:
  /// **'Futa vichujio'**
  String get actionClearFilters;

  /// No description provided for @actionShowResults.
  ///
  /// In sw, this message translates to:
  /// **'Onyesha bidhaa'**
  String get actionShowResults;

  /// No description provided for @productsEmptyTitle.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna bidhaa'**
  String get productsEmptyTitle;

  /// No description provided for @productsEmptyMessage.
  ///
  /// In sw, this message translates to:
  /// **'Jaribu neno lingine au ondoa vichujio.'**
  String get productsEmptyMessage;

  /// No description provided for @productMoq.
  ///
  /// In sw, this message translates to:
  /// **'{count, plural, =1{MOQ 1 pc} other{MOQ {count} pcs}}'**
  String productMoq(int count);

  /// No description provided for @verifiedSeller.
  ///
  /// In sw, this message translates to:
  /// **'Muuzaji Aliyethibitishwa'**
  String get verifiedSeller;

  /// No description provided for @badgeBestseller.
  ///
  /// In sw, this message translates to:
  /// **'Inauzwa Sana'**
  String get badgeBestseller;

  /// No description provided for @badgeNew.
  ///
  /// In sw, this message translates to:
  /// **'Mpya'**
  String get badgeNew;

  /// No description provided for @badgeDeal.
  ///
  /// In sw, this message translates to:
  /// **'Ofa'**
  String get badgeDeal;

  /// No description provided for @infoStock.
  ///
  /// In sw, this message translates to:
  /// **'Stock'**
  String get infoStock;

  /// No description provided for @infoDelivery.
  ///
  /// In sw, this message translates to:
  /// **'Uwasilishaji'**
  String get infoDelivery;

  /// No description provided for @stockAtLeast.
  ///
  /// In sw, this message translates to:
  /// **'{count}+ pcs'**
  String stockAtLeast(int count);

  /// No description provided for @deliveryDays.
  ///
  /// In sw, this message translates to:
  /// **'siku {min}–{max}'**
  String deliveryDays(int min, int max);

  /// No description provided for @tiersTitle.
  ///
  /// In sw, this message translates to:
  /// **'Nunua zaidi, lipa kidogo'**
  String get tiersTitle;

  /// No description provided for @tierRange.
  ///
  /// In sw, this message translates to:
  /// **'{min}–{max} pcs'**
  String tierRange(int min, int max);

  /// No description provided for @tierFrom.
  ///
  /// In sw, this message translates to:
  /// **'{min}+ pcs'**
  String tierFrom(int min);

  /// No description provided for @quantityLabel.
  ///
  /// In sw, this message translates to:
  /// **'Kiasi'**
  String get quantityLabel;

  /// No description provided for @savingsLabel.
  ///
  /// In sw, this message translates to:
  /// **'Unaokoa {amount}'**
  String savingsLabel(String amount);

  /// No description provided for @nextTierHint.
  ///
  /// In sw, this message translates to:
  /// **'Ongeza pcs {count} upate {price} kila moja'**
  String nextTierHint(int count, String price);

  /// No description provided for @actionAskSeller.
  ///
  /// In sw, this message translates to:
  /// **'Uliza Muuzaji'**
  String get actionAskSeller;

  /// No description provided for @descriptionTitle.
  ///
  /// In sw, this message translates to:
  /// **'Maelezo'**
  String get descriptionTitle;

  /// No description provided for @actionFavourite.
  ///
  /// In sw, this message translates to:
  /// **'Penda'**
  String get actionFavourite;

  /// No description provided for @actionShare.
  ///
  /// In sw, this message translates to:
  /// **'Shiriki'**
  String get actionShare;

  /// No description provided for @actionZoom.
  ///
  /// In sw, this message translates to:
  /// **'Kuza picha'**
  String get actionZoom;

  /// No description provided for @actionIncrease.
  ///
  /// In sw, this message translates to:
  /// **'Ongeza'**
  String get actionIncrease;

  /// No description provided for @actionDecrease.
  ///
  /// In sw, this message translates to:
  /// **'Punguza'**
  String get actionDecrease;

  /// No description provided for @piecesCount.
  ///
  /// In sw, this message translates to:
  /// **'{count, plural, =1{1 pc} other{{count} pcs}}'**
  String piecesCount(int count);

  /// No description provided for @cartTitle.
  ///
  /// In sw, this message translates to:
  /// **'Kikapu Chako'**
  String get cartTitle;

  /// No description provided for @actionEdit.
  ///
  /// In sw, this message translates to:
  /// **'Hariri'**
  String get actionEdit;

  /// No description provided for @actionDone.
  ///
  /// In sw, this message translates to:
  /// **'Maliza'**
  String get actionDone;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In sw, this message translates to:
  /// **'Kikapu chako ni tupu'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptyMessage.
  ///
  /// In sw, this message translates to:
  /// **'Ongeza bidhaa uanze kuagiza kwa bei za jumla.'**
  String get cartEmptyMessage;

  /// No description provided for @actionStartShopping.
  ///
  /// In sw, this message translates to:
  /// **'Anza kununua'**
  String get actionStartShopping;

  /// No description provided for @cartNudge.
  ///
  /// In sw, this message translates to:
  /// **'Ongeza pcs {count} za {product} upate {price} kila moja.'**
  String cartNudge(int count, String product, String price);

  /// No description provided for @wholesalePriceTag.
  ///
  /// In sw, this message translates to:
  /// **'Bei ya jumla'**
  String get wholesalePriceTag;

  /// No description provided for @cartTierLabel.
  ///
  /// In sw, this message translates to:
  /// **'{min}+ pcs @ {price}'**
  String cartTierLabel(int min, String price);

  /// No description provided for @moqMet.
  ///
  /// In sw, this message translates to:
  /// **'MOQ imetimia'**
  String get moqMet;

  /// No description provided for @actionRemove.
  ///
  /// In sw, this message translates to:
  /// **'Ondoa'**
  String get actionRemove;

  /// No description provided for @summaryItems.
  ///
  /// In sw, this message translates to:
  /// **'Bidhaa ({count})'**
  String summaryItems(int count);

  /// No description provided for @summaryDelivery.
  ///
  /// In sw, this message translates to:
  /// **'Usafirishaji'**
  String get summaryDelivery;

  /// No description provided for @summaryTotal.
  ///
  /// In sw, this message translates to:
  /// **'Jumla'**
  String get summaryTotal;

  /// No description provided for @summaryItemsTotal.
  ///
  /// In sw, this message translates to:
  /// **'Jumla ya Bidhaa'**
  String get summaryItemsTotal;

  /// No description provided for @summaryAmountToPay.
  ///
  /// In sw, this message translates to:
  /// **'Jumla ya Kulipa'**
  String get summaryAmountToPay;

  /// No description provided for @cartDeliveryNote.
  ///
  /// In sw, this message translates to:
  /// **'Gharama ya usafirishaji huongezwa kwenye malipo.'**
  String get cartDeliveryNote;

  /// No description provided for @actionContinueToCheckout.
  ///
  /// In sw, this message translates to:
  /// **'Endelea kwenye Malipo'**
  String get actionContinueToCheckout;

  /// No description provided for @addedToCart.
  ///
  /// In sw, this message translates to:
  /// **'Imeongezwa kikapuni.'**
  String get addedToCart;

  /// No description provided for @actionViewCart.
  ///
  /// In sw, this message translates to:
  /// **'Ona Kikapu'**
  String get actionViewCart;

  /// No description provided for @quickAddTotal.
  ///
  /// In sw, this message translates to:
  /// **'Jumla: {amount}'**
  String quickAddTotal(String amount);

  /// No description provided for @errorMoqNotMet.
  ///
  /// In sw, this message translates to:
  /// **'Kiasi ni chini ya MOQ ya bidhaa hii.'**
  String get errorMoqNotMet;

  /// No description provided for @errorOutOfStock.
  ///
  /// In sw, this message translates to:
  /// **'Stock haitoshi kwa kiasi hiki.'**
  String get errorOutOfStock;

  /// No description provided for @errorPriceChanged.
  ///
  /// In sw, this message translates to:
  /// **'Bei zimebadilika. Hakiki jumla mpya kisha uthibitishe tena.'**
  String get errorPriceChanged;

  /// No description provided for @checkoutTitle.
  ///
  /// In sw, this message translates to:
  /// **'Malipo na Usafirishaji'**
  String get checkoutTitle;

  /// No description provided for @stepAddress.
  ///
  /// In sw, this message translates to:
  /// **'Anwani'**
  String get stepAddress;

  /// No description provided for @stepDelivery.
  ///
  /// In sw, this message translates to:
  /// **'Usafirishaji'**
  String get stepDelivery;

  /// No description provided for @stepPayment.
  ///
  /// In sw, this message translates to:
  /// **'Malipo'**
  String get stepPayment;

  /// No description provided for @stepReview.
  ///
  /// In sw, this message translates to:
  /// **'Hakiki'**
  String get stepReview;

  /// No description provided for @deliveryAddressTitle.
  ///
  /// In sw, this message translates to:
  /// **'Anwani ya Uwasilishaji'**
  String get deliveryAddressTitle;

  /// No description provided for @actionChange.
  ///
  /// In sw, this message translates to:
  /// **'Badilisha'**
  String get actionChange;

  /// No description provided for @actionAddAddress.
  ///
  /// In sw, this message translates to:
  /// **'Ongeza anwani'**
  String get actionAddAddress;

  /// No description provided for @noAddressMessage.
  ///
  /// In sw, this message translates to:
  /// **'Ongeza anwani ya kupokelea oda yako.'**
  String get noAddressMessage;

  /// No description provided for @chooseDeliveryTitle.
  ///
  /// In sw, this message translates to:
  /// **'Chagua Usafirishaji'**
  String get chooseDeliveryTitle;

  /// No description provided for @deliveryTomorrow.
  ///
  /// In sw, this message translates to:
  /// **'kesho'**
  String get deliveryTomorrow;

  /// No description provided for @deliveryOption.
  ///
  /// In sw, this message translates to:
  /// **'{name} ({eta})'**
  String deliveryOption(String name, String eta);

  /// No description provided for @paymentMethodTitle.
  ///
  /// In sw, this message translates to:
  /// **'Njia ya Malipo'**
  String get paymentMethodTitle;

  /// No description provided for @payAfterOrderingHint.
  ///
  /// In sw, this message translates to:
  /// **'Utaona namba ya kulipia baada ya kuthibitisha oda.'**
  String get payAfterOrderingHint;

  /// No description provided for @payToTitle.
  ///
  /// In sw, this message translates to:
  /// **'Lipa {amount} kwa {method}'**
  String payToTitle(String amount, String method);

  /// No description provided for @payToNumber.
  ///
  /// In sw, this message translates to:
  /// **'Lipa Namba / simu'**
  String get payToNumber;

  /// No description provided for @payToBankAccount.
  ///
  /// In sw, this message translates to:
  /// **'Namba ya akaunti'**
  String get payToBankAccount;

  /// No description provided for @payToAccountName.
  ///
  /// In sw, this message translates to:
  /// **'Jina la akaunti'**
  String get payToAccountName;

  /// No description provided for @payToBank.
  ///
  /// In sw, this message translates to:
  /// **'Benki'**
  String get payToBank;

  /// No description provided for @payToNoteHint.
  ///
  /// In sw, this message translates to:
  /// **'Andika hii kama maelezo / kumbukumbu ya malipo'**
  String get payToNoteHint;

  /// No description provided for @payBefore.
  ///
  /// In sw, this message translates to:
  /// **'Lipa kabla ya {time}, la sivyo oda itaghairiwa.'**
  String payBefore(String time);

  /// No description provided for @actionCopy.
  ///
  /// In sw, this message translates to:
  /// **'Nakili'**
  String get actionCopy;

  /// No description provided for @copiedMessage.
  ///
  /// In sw, this message translates to:
  /// **'Imenakiliwa.'**
  String get copiedMessage;

  /// No description provided for @actionIPaid.
  ///
  /// In sw, this message translates to:
  /// **'Nimelipa'**
  String get actionIPaid;

  /// No description provided for @actionChangePaymentMethod.
  ///
  /// In sw, this message translates to:
  /// **'Badilisha njia ya malipo'**
  String get actionChangePaymentMethod;

  /// No description provided for @changePaymentMethodTitle.
  ///
  /// In sw, this message translates to:
  /// **'Badilisha njia ya malipo'**
  String get changePaymentMethodTitle;

  /// No description provided for @changePaymentMethodMessage.
  ///
  /// In sw, this message translates to:
  /// **'Chagua njia nyingine. Muda wa kulipa hauanzi upya.'**
  String get changePaymentMethodMessage;

  /// No description provided for @paymentMethodChanged.
  ///
  /// In sw, this message translates to:
  /// **'Sasa utalipa kwa {method}.'**
  String paymentMethodChanged(String method);

  /// No description provided for @paymentMethodChangedToCash.
  ///
  /// In sw, this message translates to:
  /// **'Oda imethibitishwa. Utalipa ukipokea.'**
  String get paymentMethodChangedToCash;

  /// No description provided for @paymentUnderReviewTitle.
  ///
  /// In sw, this message translates to:
  /// **'Tunakagua malipo yako'**
  String get paymentUnderReviewTitle;

  /// No description provided for @paymentUnderReviewMessage.
  ///
  /// In sw, this message translates to:
  /// **'Tutakujulisha tukishathibitisha. Namba ya muamala: {reference}'**
  String paymentUnderReviewMessage(String reference);

  /// No description provided for @paymentRejectedTitle.
  ///
  /// In sw, this message translates to:
  /// **'Malipo hayakuthibitishwa'**
  String get paymentRejectedTitle;

  /// No description provided for @paymentRejectedMessage.
  ///
  /// In sw, this message translates to:
  /// **'Hatukuweza kuthibitisha malipo. Angalia taarifa na utume tena.'**
  String get paymentRejectedMessage;

  /// No description provided for @paymentSheetTitle.
  ///
  /// In sw, this message translates to:
  /// **'Thibitisha malipo'**
  String get paymentSheetTitle;

  /// No description provided for @paymentSheetMessage.
  ///
  /// In sw, this message translates to:
  /// **'Weka taarifa zilizo kwenye SMS ya malipo. Tutazikagua kisha tuthibitishe oda.'**
  String get paymentSheetMessage;

  /// No description provided for @payerPhoneLabel.
  ///
  /// In sw, this message translates to:
  /// **'Namba uliyolipia'**
  String get payerPhoneLabel;

  /// No description provided for @payerBankLabel.
  ///
  /// In sw, this message translates to:
  /// **'Akaunti au jina ulilolipia'**
  String get payerBankLabel;

  /// No description provided for @paymentReferenceLabel.
  ///
  /// In sw, this message translates to:
  /// **'Namba ya muamala (kwenye SMS)'**
  String get paymentReferenceLabel;

  /// No description provided for @paymentReferenceHint.
  ///
  /// In sw, this message translates to:
  /// **'mfano QJK3X7ABC1'**
  String get paymentReferenceHint;

  /// No description provided for @actionSendPayment.
  ///
  /// In sw, this message translates to:
  /// **'Tuma'**
  String get actionSendPayment;

  /// No description provided for @paymentSent.
  ///
  /// In sw, this message translates to:
  /// **'Tumepokea. Tunakagua malipo yako.'**
  String get paymentSent;

  /// No description provided for @fieldRequired.
  ///
  /// In sw, this message translates to:
  /// **'Jaza sehemu hii.'**
  String get fieldRequired;

  /// No description provided for @actionContinueToReview.
  ///
  /// In sw, this message translates to:
  /// **'Endelea Kuhakiki'**
  String get actionContinueToReview;

  /// No description provided for @reviewTitle.
  ///
  /// In sw, this message translates to:
  /// **'Hakiki Oda'**
  String get reviewTitle;

  /// No description provided for @deliveryMethodTitle.
  ///
  /// In sw, this message translates to:
  /// **'Njia ya Usafirishaji'**
  String get deliveryMethodTitle;

  /// No description provided for @orderSummaryTitle.
  ///
  /// In sw, this message translates to:
  /// **'Muhtasari wa Oda'**
  String get orderSummaryTitle;

  /// No description provided for @actionConfirmOrder.
  ///
  /// In sw, this message translates to:
  /// **'Thibitisha Oda'**
  String get actionConfirmOrder;

  /// No description provided for @paymentSecure.
  ///
  /// In sw, this message translates to:
  /// **'Malipo yako ni salama.'**
  String get paymentSecure;

  /// No description provided for @orderReceivedTitle.
  ///
  /// In sw, this message translates to:
  /// **'Oda Imepokelewa!'**
  String get orderReceivedTitle;

  /// No description provided for @orderReceivedMessage.
  ///
  /// In sw, this message translates to:
  /// **'Asante, {name}. Tumeanza kuandaa oda yako.'**
  String orderReceivedMessage(String name);

  /// No description provided for @orderNumber.
  ///
  /// In sw, this message translates to:
  /// **'#{number}'**
  String orderNumber(String number);

  /// No description provided for @actionTrackOrder.
  ///
  /// In sw, this message translates to:
  /// **'Fuatilia Oda'**
  String get actionTrackOrder;

  /// No description provided for @actionBackHome.
  ///
  /// In sw, this message translates to:
  /// **'Rudi Nyumbani'**
  String get actionBackHome;

  /// No description provided for @addressFormTitle.
  ///
  /// In sw, this message translates to:
  /// **'Anwani Mpya'**
  String get addressFormTitle;

  /// No description provided for @editAddressFormTitle.
  ///
  /// In sw, this message translates to:
  /// **'Hariri Anwani'**
  String get editAddressFormTitle;

  /// No description provided for @addressesEmpty.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna anwani bado'**
  String get addressesEmpty;

  /// No description provided for @defaultAddressLabel.
  ///
  /// In sw, this message translates to:
  /// **'Chaguo-msingi'**
  String get defaultAddressLabel;

  /// No description provided for @addressActions.
  ///
  /// In sw, this message translates to:
  /// **'Vitendo vya anwani'**
  String get addressActions;

  /// No description provided for @actionEditAddress.
  ///
  /// In sw, this message translates to:
  /// **'Hariri'**
  String get actionEditAddress;

  /// No description provided for @actionSetDefaultAddress.
  ///
  /// In sw, this message translates to:
  /// **'Fanya chaguo-msingi'**
  String get actionSetDefaultAddress;

  /// No description provided for @deleteAddressConfirmTitle.
  ///
  /// In sw, this message translates to:
  /// **'Futa anwani?'**
  String get deleteAddressConfirmTitle;

  /// No description provided for @deleteAddressConfirmMessage.
  ///
  /// In sw, this message translates to:
  /// **'Anwani hii itaondolewa kwenye anwani zako za usafirishaji.'**
  String get deleteAddressConfirmMessage;

  /// No description provided for @recipientNameLabel.
  ///
  /// In sw, this message translates to:
  /// **'Jina la mpokeaji'**
  String get recipientNameLabel;

  /// No description provided for @streetLabel.
  ///
  /// In sw, this message translates to:
  /// **'Mtaa / eneo'**
  String get streetLabel;

  /// No description provided for @streetHint.
  ///
  /// In sw, this message translates to:
  /// **'Mfano: Kariakoo, Mtaa wa Lumumba'**
  String get streetHint;

  /// No description provided for @streetRequired.
  ///
  /// In sw, this message translates to:
  /// **'Andika mtaa au eneo.'**
  String get streetRequired;

  /// No description provided for @landmarkLabel.
  ///
  /// In sw, this message translates to:
  /// **'Alama ya karibu'**
  String get landmarkLabel;

  /// No description provided for @actionSaveAddress.
  ///
  /// In sw, this message translates to:
  /// **'Hifadhi anwani'**
  String get actionSaveAddress;

  /// No description provided for @chooseAddressTitle.
  ///
  /// In sw, this message translates to:
  /// **'Chagua anwani'**
  String get chooseAddressTitle;

  /// No description provided for @ordersTitle.
  ///
  /// In sw, this message translates to:
  /// **'Oda Zangu'**
  String get ordersTitle;

  /// No description provided for @tabActiveOrders.
  ///
  /// In sw, this message translates to:
  /// **'Zinazoendelea'**
  String get tabActiveOrders;

  /// No description provided for @tabDeliveredOrders.
  ///
  /// In sw, this message translates to:
  /// **'Zimefika'**
  String get tabDeliveredOrders;

  /// No description provided for @ordersEmptyTitle.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna oda hapa'**
  String get ordersEmptyTitle;

  /// No description provided for @ordersEmptyMessage.
  ///
  /// In sw, this message translates to:
  /// **'Oda zako zitaonekana hapa.'**
  String get ordersEmptyMessage;

  /// No description provided for @statusPendingPayment.
  ///
  /// In sw, this message translates to:
  /// **'Inasubiri malipo'**
  String get statusPendingPayment;

  /// No description provided for @statusConfirmed.
  ///
  /// In sw, this message translates to:
  /// **'Imethibitishwa'**
  String get statusConfirmed;

  /// No description provided for @statusPacked.
  ///
  /// In sw, this message translates to:
  /// **'Imepakiwa'**
  String get statusPacked;

  /// No description provided for @statusDispatched.
  ///
  /// In sw, this message translates to:
  /// **'Imetumwa'**
  String get statusDispatched;

  /// No description provided for @statusInTransit.
  ///
  /// In sw, this message translates to:
  /// **'Inasafirishwa'**
  String get statusInTransit;

  /// No description provided for @statusDelivered.
  ///
  /// In sw, this message translates to:
  /// **'Imewasili'**
  String get statusDelivered;

  /// No description provided for @statusCancelled.
  ///
  /// In sw, this message translates to:
  /// **'Imeghairiwa'**
  String get statusCancelled;

  /// No description provided for @statusExpired.
  ///
  /// In sw, this message translates to:
  /// **'Muda umeisha'**
  String get statusExpired;

  /// No description provided for @trackingPendingPayment.
  ///
  /// In sw, this message translates to:
  /// **'Kamilisha malipo ili tuanze kuandaa oda yako.'**
  String get trackingPendingPayment;

  /// No description provided for @trackingConfirmed.
  ///
  /// In sw, this message translates to:
  /// **'Tunaandaa oda yako.'**
  String get trackingConfirmed;

  /// No description provided for @trackingPacked.
  ///
  /// In sw, this message translates to:
  /// **'Oda yako iko tayari kutumwa.'**
  String get trackingPacked;

  /// No description provided for @trackingDispatched.
  ///
  /// In sw, this message translates to:
  /// **'Oda yako imekabidhiwa wakala.'**
  String get trackingDispatched;

  /// No description provided for @trackingInTransitTitle.
  ///
  /// In sw, this message translates to:
  /// **'Njiani'**
  String get trackingInTransitTitle;

  /// No description provided for @trackingInTransit.
  ///
  /// In sw, this message translates to:
  /// **'Oda yako inakuja.'**
  String get trackingInTransit;

  /// No description provided for @trackingDelivered.
  ///
  /// In sw, this message translates to:
  /// **'Asante kwa kununua CHIMBO!'**
  String get trackingDelivered;

  /// No description provided for @trackingCancelled.
  ///
  /// In sw, this message translates to:
  /// **'Oda hii imeghairiwa.'**
  String get trackingCancelled;

  /// No description provided for @trackingExpired.
  ///
  /// In sw, this message translates to:
  /// **'Muda wa malipo umeisha.'**
  String get trackingExpired;

  /// No description provided for @estimatedDeliveryTitle.
  ///
  /// In sw, this message translates to:
  /// **'Makadirio ya Uwasilishaji'**
  String get estimatedDeliveryTitle;

  /// No description provided for @deliveredOnTitle.
  ///
  /// In sw, this message translates to:
  /// **'Imefika tarehe'**
  String get deliveredOnTitle;

  /// No description provided for @actionDownloadReceipt.
  ///
  /// In sw, this message translates to:
  /// **'Pakua Risiti'**
  String get actionDownloadReceipt;

  /// No description provided for @reorderDone.
  ///
  /// In sw, this message translates to:
  /// **'Bidhaa zimerudishwa kikapuni.'**
  String get reorderDone;

  /// No description provided for @deliveryAgentTitle.
  ///
  /// In sw, this message translates to:
  /// **'Wakala wa Uwasilishaji'**
  String get deliveryAgentTitle;

  /// No description provided for @actionCall.
  ///
  /// In sw, this message translates to:
  /// **'Piga simu'**
  String get actionCall;

  /// No description provided for @actionMessage.
  ///
  /// In sw, this message translates to:
  /// **'Tuma ujumbe'**
  String get actionMessage;

  /// No description provided for @actionCancelOrder.
  ///
  /// In sw, this message translates to:
  /// **'Ghairi oda'**
  String get actionCancelOrder;

  /// No description provided for @cancelOrderConfirmTitle.
  ///
  /// In sw, this message translates to:
  /// **'Ghairi oda hii?'**
  String get cancelOrderConfirmTitle;

  /// No description provided for @cancelOrderConfirmMessage.
  ///
  /// In sw, this message translates to:
  /// **'Oda itaghairiwa na bidhaa kurudishwa stock. Huwezi kutendua hili.'**
  String get cancelOrderConfirmMessage;

  /// No description provided for @orderCancelledMessage.
  ///
  /// In sw, this message translates to:
  /// **'Oda imeghairiwa.'**
  String get orderCancelledMessage;

  /// No description provided for @orderItemLine.
  ///
  /// In sw, this message translates to:
  /// **'{quantity} × {price}'**
  String orderItemLine(int quantity, String price);

  /// No description provided for @savedToWishlist.
  ///
  /// In sw, this message translates to:
  /// **'Imehifadhiwa kwenye vipendwa.'**
  String get savedToWishlist;

  /// No description provided for @actionUnfavourite.
  ///
  /// In sw, this message translates to:
  /// **'Ondoa kwenye vipendwa'**
  String get actionUnfavourite;

  /// No description provided for @discountPercent.
  ///
  /// In sw, this message translates to:
  /// **'-{percent}%'**
  String discountPercent(int percent);

  /// No description provided for @menuWishlist.
  ///
  /// In sw, this message translates to:
  /// **'Vipendwa'**
  String get menuWishlist;

  /// No description provided for @menuWishlistHint.
  ///
  /// In sw, this message translates to:
  /// **'Bidhaa ulizohifadhi'**
  String get menuWishlistHint;

  /// No description provided for @wishlistEmptyTitle.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna vipendwa bado'**
  String get wishlistEmptyTitle;

  /// No description provided for @wishlistEmptyMessage.
  ///
  /// In sw, this message translates to:
  /// **'Gusa ♡ kwenye bidhaa ili kuihifadhi hapa.'**
  String get wishlistEmptyMessage;

  /// No description provided for @outOfStock.
  ///
  /// In sw, this message translates to:
  /// **'Imeisha'**
  String get outOfStock;

  /// No description provided for @actionOutOfStock.
  ///
  /// In sw, this message translates to:
  /// **'Imeisha stock'**
  String get actionOutOfStock;

  /// Shown only when a test server sends the code (never in production).
  ///
  /// In sw, this message translates to:
  /// **'Hali ya majaribio: namba ni {code}'**
  String otpTestModeHint(String code);

  /// No description provided for @cartProblemNotEnoughStock.
  ///
  /// In sw, this message translates to:
  /// **'Stock haitoshi — zimebaki {count}'**
  String cartProblemNotEnoughStock(int count);

  /// No description provided for @cartProblemBelowMoq.
  ///
  /// In sw, this message translates to:
  /// **'Chini ya MOQ ({moq})'**
  String cartProblemBelowMoq(int moq);

  /// No description provided for @cartFixLowerTo.
  ///
  /// In sw, this message translates to:
  /// **'Punguza hadi {count}'**
  String cartFixLowerTo(int count);

  /// No description provided for @cartFixRaiseTo.
  ///
  /// In sw, this message translates to:
  /// **'Ongeza hadi {count}'**
  String cartFixRaiseTo(int count);

  /// No description provided for @cartCannotCheckout.
  ///
  /// In sw, this message translates to:
  /// **'Rekebisha bidhaa zilizowekwa alama nyekundu ili kuendelea.'**
  String get cartCannotCheckout;

  /// No description provided for @summarySavings.
  ///
  /// In sw, this message translates to:
  /// **'Unaokoa'**
  String get summarySavings;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
