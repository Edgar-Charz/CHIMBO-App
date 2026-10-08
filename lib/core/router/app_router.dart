import 'package:chimbo/core/router/app_routes.dart';
import 'package:chimbo/core/router/auth_redirect.dart';
import 'package:chimbo/features/addresses/presentation/address_form_screen.dart';
import 'package:chimbo/features/auth/application/auth_controller.dart';
import 'package:chimbo/features/auth/presentation/business_info_screen.dart';
import 'package:chimbo/features/auth/presentation/create_pin_screen.dart';
import 'package:chimbo/features/auth/presentation/otp_screen.dart';
import 'package:chimbo/features/auth/presentation/phone_screen.dart';
import 'package:chimbo/features/auth/presentation/pin_login_screen.dart';
import 'package:chimbo/features/cart/presentation/cart_screen.dart';
import 'package:chimbo/features/catalog/data/models/product_query.dart';
import 'package:chimbo/features/catalog/presentation/product_details_screen.dart';
import 'package:chimbo/features/catalog/presentation/product_list_screen.dart';
import 'package:chimbo/features/checkout/presentation/checkout_screen.dart';
import 'package:chimbo/features/checkout/presentation/review_screen.dart';
import 'package:chimbo/features/debug/presentation/debug_screen.dart';
import 'package:chimbo/features/home/presentation/home_screen.dart';
import 'package:chimbo/features/notifications/presentation/notifications_screen.dart';
import 'package:chimbo/features/onboarding/presentation/onboarding_screen.dart';
import 'package:chimbo/features/onboarding/presentation/splash_screen.dart';
import 'package:chimbo/features/orders/presentation/order_success_screen.dart';
import 'package:chimbo/features/orders/presentation/order_tracking_screen.dart';
import 'package:chimbo/features/orders/presentation/orders_screen.dart';
import 'package:chimbo/features/profile/presentation/change_pin_screen.dart';
import 'package:chimbo/features/profile/presentation/edit_profile_screen.dart';
import 'package:chimbo/features/profile/presentation/profile_screen.dart';
import 'package:chimbo/features/profile/presentation/settings_screen.dart';
import 'package:chimbo/features/shell/presentation/main_shell.dart';
import 'package:chimbo/features/support/data/models/legal_page.dart';
import 'package:chimbo/features/support/presentation/help_screen.dart';
import 'package:chimbo/features/support/presentation/legal_page_screen.dart';
import 'package:chimbo/features/wishlist/presentation/wishlist_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// App navigation. The 5 bottom tabs live in a [StatefulShellRoute], so each tab keeps its own
/// history and scroll position when the user switches tabs.
///
/// Every navigation passes [authRedirect], and the router re-checks it whenever the login state
/// changes — so logging in, finishing step 3 or logging out moves to the right screen by itself.
final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) => authRedirect(
      ref.read(authControllerProvider).status,
      state.matchedLocation,
    ),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.phone,
        builder: (context, state) => const PhoneScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        // The number comes from the phone screen; without it (e.g. app restored) start over.
        redirect: (context, state) =>
            state.extra is OtpScreenArgs ? null : AppRoutes.phone,
        builder: (context, state) =>
            OtpScreen(args: state.extra! as OtpScreenArgs),
      ),
      GoRoute(
        path: AppRoutes.pinLogin,
        // The number comes from the phone screen; without it (e.g. app restored) start over.
        redirect: (context, state) =>
            state.extra is PinLoginArgs ? null : AppRoutes.phone,
        builder: (context, state) =>
            PinLoginScreen(args: state.extra! as PinLoginArgs),
      ),
      GoRoute(
        path: AppRoutes.createPin,
        builder: (context, state) => const CreatePinScreen(),
      ),
      GoRoute(
        path: AppRoutes.businessInfo,
        builder: (context, state) => const BusinessInfoScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
                // From the bell, inside the Nyumbani tab.
                routes: [
                  GoRoute(
                    path: _childPath(AppRoutes.notifications),
                    builder: (context, state) => const NotificationsScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.discover,
                // Home's quick actions open Gundua with `?collection=deals` etc.
                builder: (context, state) => ProductListScreen(
                  key: ValueKey(state.uri.queryParameters['collection']),
                  collection: ProductCollection.fromApi(
                    state.uri.queryParameters['collection'],
                  ),
                ),
                routes: [
                  GoRoute(
                    path: _childPath(AppRoutes.categoryPattern, levels: 2),
                    builder: (context, state) => ProductListScreen(
                      categoryId: int.parse(
                        state.pathParameters['categoryId']!,
                      ),
                      collection: ProductCollection.fromApi(
                        state.uri.queryParameters['collection'],
                      ),
                      forceProductList:
                          state.uri.queryParameters['listing'] == '1',
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.cart,
                builder: (context, state) => const CartScreen(),
                // Inside the Kikapu tab, as in the design.
                routes: [
                  GoRoute(
                    path: _childPath(AppRoutes.checkout),
                    builder: (context, state) => const CheckoutScreen(),
                    routes: [
                      GoRoute(
                        path: _childPath(AppRoutes.checkoutReview),
                        builder: (context, state) => const ReviewScreen(),
                      ),
                      GoRoute(
                        path: _childPath(AppRoutes.addressForm),
                        builder: (context, state) => const AddressFormScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.orders,
                builder: (context, state) => const OrdersScreen(),
                routes: [
                  GoRoute(
                    path: _childPath(AppRoutes.orderPattern),
                    builder: (context, state) => OrderTrackingScreen(
                      orderId: int.parse(state.pathParameters['orderId']!),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
                // Inside the tab, so the bottom bar stays visible.
                routes: [
                  GoRoute(
                    path: _childPath(AppRoutes.profileEdit),
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: _childPath(AppRoutes.settings),
                    builder: (context, state) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: _childPath(AppRoutes.wishlist),
                    builder: (context, state) => const WishlistScreen(),
                  ),
                  GoRoute(
                    path: _childPath(AppRoutes.changePin),
                    builder: (context, state) => const ChangePinScreen(),
                  ),
                  GoRoute(
                    path: _childPath(AppRoutes.help),
                    builder: (context, state) => const HelpScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // Full screen (no bottom bar), as in the design.
      GoRoute(
        path: AppRoutes.orderSuccessPattern,
        builder: (context, state) => OrderSuccessScreen(
          orderId: int.parse(state.pathParameters['orderId']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.legalPagePattern,
        // Only the pages the server has; anything else goes to the start.
        redirect: (context, state) =>
            LegalPageType.fromApi(state.pathParameters['name']!) == null
            ? AppRoutes.home
            : null,
        builder: (context, state) => LegalPageScreen(
          type: LegalPageType.fromApi(state.pathParameters['name']!)!,
        ),
      ),
      GoRoute(
        path: AppRoutes.productPattern,
        builder: (context, state) => ProductDetailsScreen(
          productId: int.parse(state.pathParameters['productId']!),
        ),
      ),
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.debug,
          builder: (context, state) => const DebugScreen(),
        ),
    ],
  );
  ref.listen(authControllerProvider, (previous, next) => router.refresh());
  ref.onDispose(router.dispose);
  return router;
});

/// '/profile/edit' → 'edit': child routes are written relative to their parent.
/// [levels] > 1 keeps more of the end ('/discover/category/:id' → 'category/:id').
String _childPath(String fullPath, {int levels = 1}) {
  final parts = fullPath.split('/');
  return parts.sublist(parts.length - levels).join('/');
}
