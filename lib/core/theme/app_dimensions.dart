/// Spacing scale used for padding, margins and gaps.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Corner radii (blueprint §6.3: 12–16 px).
abstract final class AppRadius {
  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
}

/// Fixed component sizes. Tap targets stay large for budget phones.
abstract final class AppSizes {
  static const double buttonHeight = 52;
  static const double buttonProgress = 20;
  static const double iconSmall = 16;
  static const double iconMedium = 20;
  static const double iconLarge = 64;
  static const double navigationIcon = 26;
  static const double borderWidth = 1;

  static const double pageDot = 8;
  static const double pageDotActiveWidth = 22;
  static const double splashLogo = 120;
  static const double savingsSeal = 68;

  static const double stepDot = 8;
  static const double stepDotCurrent = 12;
  static const double stepLine = 36;
  static const double otpBoxWidth = 46;
  static const double otpBoxHeight = 56;
  static const double headerLogo = 56;
  static const double avatarRadius = 40;
  static const double menuIconBox = 44;
  static const double stepperValueWidth = 40;

  static const double railCardWidth = 150;
  static const double quickActionIcon = 56;
  static const double categoryCardImage = 110;
  static const double bannerImageWidth = 112;
  static const double galleryThumbnail = 64;
  static const double loadMoreThreshold = 400;
  static const double cartLineImage = 88;
  static const double compactStepperHeight = 34;
  static const double orderThumbnail = 56;
  static const double successBadge = 120;
  static const double timelineDot = 36;
  static const double categoryHeaderExtra = 20;
  static const double stepCircle = 30;
  static const double toastElevation = 6;
  static const double recentOrderTile = 104;
  static const double cardElevation = 2;
  static const double pinKey = 56;
  static const double pinDot = 14;

  /// Height of chips and filter pills in listings (still comfortable to tap).
  static const double compactControl = 36;
}

/// Animation lengths, so motion feels the same across the app.
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 700);

  /// A second back within this time closes the app (as long as the toast shows).
  static const Duration exitConfirmWindow = Duration(seconds: 3);
}
