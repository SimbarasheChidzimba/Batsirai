import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/restaurants/presentation/screens/restaurants_screen.dart';
import '../features/restaurants/presentation/restaurant_detail_screen.dart';
import '../features/restaurants/presentation/screens/booking_screen.dart';
import '../features/events/presentation/screens/events_screen.dart';
import '../features/events/presentation/screens/event_detail_screen.dart';
import '../features/events/presentation/screens/ticket_purchase_screen.dart';
import '../features/membership/presentation/screens/membership_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/favorites_screen.dart';
import '../features/profile/presentation/screens/notifications_screen.dart';
import '../features/profile/presentation/screens/privacy_screen.dart';
import '../features/profile/presentation/screens/about_us_screen.dart';
import '../features/profile/presentation/screens/privacy_policy_screen.dart';
import '../features/profile/presentation/screens/terms_of_service_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/presentation/screens/signup_success_screen.dart';
import '../features/bookings/presentation/screens/payment_screen.dart';
import '../features/bookings/presentation/screens/booking_success_screen.dart';
import '../features/bookings/presentation/screens/stripe_checkout_webview_screen.dart';
import '../features/bookings/presentation/bookings_list_screen.dart';
import '../features/bookings/presentation/providers/booking_providers.dart';
import '../core/widgets/bottom_nav_bar.dart';

part 'router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

@riverpod
GoRouter router(RouterRef ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithBottomNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Home Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
              ),
            ],
          ),

          // Restaurants Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/restaurants',
                name: 'restaurants',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: RestaurantsScreen(),
                ),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: 'restaurant-detail',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return RestaurantDetailScreen(restaurantId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'book',
                        name: 'booking',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return BookingScreen(restaurantId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Events Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/events',
                name: 'events',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: EventsScreen(),
                ),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: 'event-detail',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return EventDetailScreen(eventId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'tickets',
                        name: 'ticket-purchase',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return TicketPurchaseScreen(eventId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Membership Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/membership',
                name: 'membership',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: MembershipScreen(),
                ),
              ),
            ],
          ),

          // Profile Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfileScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'bookings',
                    name: 'profile-bookings',
                    builder: (context, state) => const BookingsListScreen(),
                  ),
                  GoRoute(
                    path: 'edit',
                    name: 'profile-edit',
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'favorites',
                    name: 'profile-favorites',
                    builder: (context, state) => const FavoritesScreen(),
                  ),
                  GoRoute(
                    path: 'notifications',
                    name: 'profile-notifications',
                    builder: (context, state) => const NotificationsScreen(),
                  ),
                  GoRoute(
                    path: 'privacy',
                    name: 'profile-privacy',
                    builder: (context, state) => const PrivacyScreen(),
                  ),
                  GoRoute(
                    path: 'about',
                    name: 'profile-about',
                    builder: (context, state) => const AboutUsScreen(),
                  ),
                  GoRoute(
                    path: 'privacy-policy',
                    name: 'privacy-policy',
                    builder: (context, state) => const PrivacyPolicyScreen(),
                  ),
                  GoRoute(
                    path: 'terms-of-service',
                    name: 'terms-of-service',
                    builder: (context, state) => const TermsOfServiceScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/signup-success',
        name: 'signup-success',
        builder: (context, state) => const SignupSuccessScreen(),
      ),
      // Booking routes
      GoRoute(
        path: '/payment',
        name: 'payment',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          
          // If no extra data provided, try to get from pending booking data
          // This handles the case where user logs in and we navigate to payment
          Map<String, dynamic> bookingData;
          if (extra != null && extra.isNotEmpty) {
            bookingData = extra;
          } else {
            // Try to get from provider (requires WidgetRef, so we'll handle in the screen)
            bookingData = {};
          }
          
          return PaymentScreen(
            type: bookingData['type'] ?? 'restaurant',
            bookingData: bookingData['bookingData'] ?? {},
            amount: (bookingData['amount'] as num?)?.toDouble() ?? 0.0,
          );
        },
      ),
      GoRoute(
        path: '/booking-success',
        name: 'booking-success',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return BookingSuccessScreen(
            type: extra['type'] as String?,
            bookingData: extra['bookingData'] as Map<String, dynamic>?,
            amount: extra['amount']?.toDouble(),
          );
        },
      ),
      GoRoute(
        path: '/bookings',
        name: 'bookings',
        builder: (context, state) => const BookingsListScreen(),
      ),
      GoRoute(
        path: '/stripe-checkout',
        name: 'stripe-checkout',
        builder: (context, state) {
          final url = state.extra as String? ?? '';
          return StripeCheckoutWebViewScreen(checkoutUrl: url);
        },
      ),
    ],
  );
}
