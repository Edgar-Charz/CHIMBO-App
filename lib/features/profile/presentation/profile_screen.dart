import 'package:chimbo/core/l10n/l10n.dart';
import 'package:chimbo/core/network/api_exception.dart';
import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/theme/app_colors.dart';
import 'package:chimbo/core/theme/app_dimensions.dart';
import 'package:chimbo/core/widgets/app_button.dart';
import 'package:chimbo/core/widgets/app_toast.dart';
import 'package:chimbo/core/widgets/confirm_dialog.dart';
import 'package:chimbo/core/widgets/error_state.dart';
import 'package:chimbo/features/auth/application/auth_controller.dart';
import 'package:chimbo/features/auth/data/models/app_user.dart';
import 'package:chimbo/features/profile/application/profile_controller.dart';
import 'package:chimbo/features/profile/data/models/business_profile.dart';
import 'package:chimbo/features/profile/data/models/profile.dart';
import 'package:chimbo/features/profile/presentation/widgets/profile_card.dart';
import 'package:chimbo/features/profile/presentation/widgets/profile_menu_tile.dart';
import 'package:chimbo/features/profile/presentation/widgets/profile_photo_sheet.dart';
import 'package:chimbo/features/support/data/models/legal_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Wasifu tab (design PDF p.11): profile card, menu, logout.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  // Shape-only stand-in drawn as grey blocks while the real profile loads.
  static const Profile _skeletonProfile = Profile(
    user: AppUser(id: 0, phone: '+255700000000', fullName: 'Jina Kamili'),
    business: BusinessProfile(regionId: 0, regionName: 'Dar es Salaam'),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: profile.when(
          data: (value) => _ProfileContent(profile: value),
          error: (error, _) => ErrorState(
            error: error,
            onRetry: () => ref.invalidate(profileControllerProvider),
          ),
          loading: () => const Skeletonizer(
            child: _ProfileContent(profile: _skeletonProfile),
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.profile});

  final Profile profile;

  // Phone photos are shrunk before upload: well under the server's 8 MB, still sharp at 300 px.
  static const double _photoMaxSide = 1080;
  static const int _photoQuality = 85;

  /// Pick / take / remove the profile photo; the server's reason is shown if it refuses one.
  Future<void> _changePhoto(BuildContext context, WidgetRef ref) async {
    final toast = AppToast.of(context);
    final l10n = context.l10n;
    final controller = ref.read(profileControllerProvider.notifier);
    final action = await showProfilePhotoSheet(
      context,
      hasPhoto: profile.user.avatarUrl != null,
    );
    try {
      switch (action) {
        case null:
          return;
        case ProfilePhotoAction.remove:
          await controller.removePhoto();
          toast.success(l10n.profilePhotoRemoved);
        case ProfilePhotoAction.gallery || ProfilePhotoAction.camera:
          final photo = await ImagePicker().pickImage(
            source: action == ProfilePhotoAction.camera
                ? ImageSource.camera
                : ImageSource.gallery,
            maxWidth: _photoMaxSide,
            maxHeight: _photoMaxSide,
            imageQuality: _photoQuality,
          );
          if (photo == null) {
            return;
          }
          toast.info(l10n.profilePhotoUploading);
          await controller.changePhoto(photo.path);
          toast.success(l10n.profilePhotoSaved);
      }
    } on ApiException catch (error) {
      toast.error(l10n.errorMessage(error));
    }
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.logoutConfirmTitle,
      message: l10n.logoutConfirmMessage,
      confirmLabel: l10n.actionLogout,
      isDestructive: true,
    );
    if (confirmed) {
      // The router moves to the phone screen once the state changes.
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final menu = [
      ProfileMenuTile(
        icon: Icons.storefront_outlined,
        tone: MenuTone.green,
        title: l10n.menuBusinessInfo,
        subtitle: l10n.menuBusinessInfoHint,
        onTap: () => context.push(AppRoutes.profileEdit),
      ),
      ProfileMenuTile(
        icon: Icons.favorite_border_rounded,
        tone: MenuTone.red,
        title: l10n.menuWishlist,
        subtitle: l10n.menuWishlistHint,
        onTap: () => context.push(AppRoutes.wishlist),
      ),
      ProfileMenuTile(
        icon: Icons.location_on_outlined,
        tone: MenuTone.orange,
        title: l10n.menuAddresses,
        subtitle: l10n.menuAddressesHint,
        onTap: () => context.push(AppRoutes.profileAddresses),
      ),
      ProfileMenuTile(
        icon: Icons.account_balance_wallet_outlined,
        tone: MenuTone.gold,
        title: l10n.menuPayments,
        subtitle: l10n.menuPaymentsHint,
        onTap: () => context.push(AppRoutes.myPayments),
      ),
      ProfileMenuTile(
        icon: Icons.receipt_long_outlined,
        tone: MenuTone.blue,
        title: l10n.menuReceipts,
        subtitle: l10n.menuReceiptsHint,
        onTap: () => context.go(AppRoutes.orders),
      ),
      ProfileMenuTile(
        icon: Icons.notifications_none_rounded,
        tone: MenuTone.purple,
        title: l10n.menuNotifications,
        subtitle: l10n.menuNotificationsHint,
        onTap: () => context.push(AppRoutes.notifications),
      ),
      ProfileMenuTile(
        icon: Icons.headset_mic_outlined,
        tone: MenuTone.green,
        title: l10n.menuHelp,
        subtitle: l10n.menuHelpHint,
        onTap: () => context.push(AppRoutes.help),
      ),
      ProfileMenuTile(
        icon: Icons.description_outlined,
        tone: MenuTone.grey,
        title: l10n.menuTerms,
        subtitle: l10n.menuTermsHint,
        onTap: () => context.push(AppRoutes.legalPage(LegalPageType.terms)),
      ),
      ProfileMenuTile(
        icon: Icons.privacy_tip_outlined,
        tone: MenuTone.grey,
        title: l10n.menuPrivacy,
        subtitle: l10n.menuPrivacyHint,
        onTap: () => context.push(AppRoutes.legalPage(LegalPageType.privacy)),
      ),
      ProfileMenuTile(
        icon: Icons.lock_outline_rounded,
        tone: MenuTone.gold,
        title: l10n.menuChangePin,
        subtitle: l10n.menuChangePinHint,
        onTap: () => context.push(AppRoutes.changePin),
      ),
      ProfileMenuTile(
        icon: Icons.settings_outlined,
        tone: MenuTone.grey,
        title: l10n.menuSettings,
        subtitle: l10n.menuSettingsHint,
        onTap: () => context.push(AppRoutes.settings),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const _Header(),
        const SizedBox(height: AppSpacing.lg),
        ProfileCard(
          profile: profile,
          onEdit: () => context.push(AppRoutes.profileEdit),
          onChangePhoto: () => _changePhoto(context, ref),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final tile in menu) ...[
          tile,
          const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: l10n.logoutAccount,
          icon: Icons.logout_rounded,
          variant: AppButtonVariant.danger,
          onPressed: () => _confirmLogout(context, ref),
        ),
      ],
    );
  }
}

/// Big "Wasifu" title with the settings shortcut on the right.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.navProfile,
            style: textTheme.headlineSmall?.copyWith(color: AppColors.primary),
          ),
        ),
        InkWell(
          onTap: () => context.push(AppRoutes.settings),
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Column(
              children: [
                const Icon(Icons.settings_outlined, color: AppColors.primary),
                Text(l10n.menuSettings, style: textTheme.labelSmall),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
