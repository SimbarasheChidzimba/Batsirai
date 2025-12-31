import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/restaurants/presentation/screens/restaurants_screen.dart';
import '../features/restaurants/presentation/screens/restaurant_detail_screen.dart';
import '../features/restaurants/presentation/screens/booking_screen.dart';
import '../features/events/presentation/screens/events_screen.dart';
import '../features/events/presentation/screens/event_detail_screen.dart';
import '../features/events/presentation/screens/ticket_purchase_screen.dart';
import '../features/membership/presentation/screens/membership_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../core/widgets/bottom_nav_bar.dart';

part 'router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

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
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
