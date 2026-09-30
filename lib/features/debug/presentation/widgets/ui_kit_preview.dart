import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/app_button.dart';
import 'package:chimbo/core/widgets/app_text_field.dart';
import 'package:chimbo/core/widgets/cart_icon_badge.dart';
import 'package:chimbo/core/widgets/price_text.dart';
import 'package:chimbo/core/widgets/verified_badge.dart';
import 'package:flutter/material.dart';

/// Every shared widget in one place, to check the look on a real phone.
class UiKitPreview extends StatelessWidget {
  const UiKitPreview({super.key});

  static const int _samplePrice = 5500;
  static const int _sampleBestPrice = 4400;
  static const int _sampleCartCount = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const gap = SizedBox(height: AppSpacing.md);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(label: l10n.actionContinue, onPressed: () {}),
        gap,
        AppButton(
          label: l10n.actionAddToCart,
          icon: Icons.add_shopping_cart_rounded,
          variant: AppButtonVariant.accent,
          onPressed: () {},
        ),
        gap,
        AppButton(
          label: l10n.actionRetry,
          variant: AppButtonVariant.outlined,
          onPressed: () {},
        ),
        gap,
        AppButton(
          label: l10n.actionContinue,
          isLoading: true,
          onPressed: () {},
        ),
        gap,
        AppTextField(
          label: l10n.phoneLabel,
          hint: l10n.phoneHint,
          keyboardType: TextInputType.phone,
          prefix: const Icon(Icons.phone_outlined),
        ),
        gap,
        const Wrap(
          spacing: AppSpacing.xl,
          runSpacing: AppSpacing.md,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            PriceText(_samplePrice),
            PriceText(_sampleBestPrice, highlight: true),
            VerifiedBadge(),
            CartIconBadge(count: _sampleCartCount),
          ],
        ),
      ],
    );
  }
}
