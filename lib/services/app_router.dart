import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/restaurants/presentation/restaurants_screen.dart';
import '../features/restaurants/presentation/restaurant_detail_screen.dart';
import '../features/events/presentation/events_screen.dart';
import '../features/events/presentation/event_detail_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/membership/presentation/membership_screen.dart';
import '../features/bookings/presentation/restaurant_booking_screen.dart';
import '../features/bookings/presentation/event_booking_screen.dart';
import '../features/bookings/presentation/bookings_list_screen.dart';
import 'scaffold_with_nav_bar.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

class AppRouter {
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      // Auth routes (no bottom nav)
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
      
      // Main app with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Home branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'membership',
                    name: 'membership',
                    builder: (context, state) => const MembershipScreen(),
                  ),
                ],
              ),
            ],
          ),
          
          // Restaurants branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/restaurants',
                name: 'restaurants',
                builder: (context, state) => const RestaurantsScreen(),
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
                        name: 'restaurant-booking',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return RestaurantBookingScreen(restaurantId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          
          // Events branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/events',
                name: 'events',
                builder: (context, state) => const EventsScreen(),
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
                        path: 'book',
                        name: 'event-booking',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return EventBookingScreen(eventId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          
          // Profile branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'bookings',
                    name: 'bookings',
                    builder: (context, state) => const BookingsListScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
