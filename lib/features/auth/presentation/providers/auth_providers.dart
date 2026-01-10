import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/user.dart';
import '../../domain/user.dart';
import '../domain/user.dart';

// Current user provider (mock implementation)
final currentUserProvider = StateProvider<User?>((ref) {
  // Mock user - in production, this would come from Firebase Auth
  return null; // Start with no user (not logged in)
});

// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

// Is premium member provider
final isPremiumMemberProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isPremiumMember ?? false;
});

// User membership tier provider
final membershipTierProvider = Provider<MembershipTier>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.membershipTier ?? MembershipTier.free;
});

// Favorite restaurants provider
final favoriteRestaurantIdsProvider = StateProvider<List<String>>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.favoriteRestaurantIds ?? [];
});

// Favorite events provider
final favoriteEventIdsProvider = StateProvider<List<String>>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.favoriteEventIds ?? [];
});

// Check if restaurant is favorite
final isRestaurantFavoriteProvider = Provider.family<bool, String>((ref, restaurantId) {
  final favorites = ref.watch(favoriteRestaurantIdsProvider);
  return favorites.contains(restaurantId);
});

// Check if event is favorite
final isEventFavoriteProvider = Provider.family<bool, String>((ref, eventId) {
  final favorites = ref.watch(favoriteEventIdsProvider);
  return favorites.contains(eventId);
});

// Toggle restaurant favorite
class FavoriteRestaurantNotifier extends StateNotifier<List<String>> {
  FavoriteRestaurantNotifier() : super([]);

  void toggle(String restaurantId) {
    if (state.contains(restaurantId)) {
      state = state.where((id) => id != restaurantId).toList();
    } else {
      state = [...state, restaurantId];
    }
  }

  void add(String restaurantId) {
    if (!state.contains(restaurantId)) {
      state = [...state, restaurantId];
    }
  }

  void remove(String restaurantId) {
    state = state.where((id) => id != restaurantId).toList();
  }
}

final favoriteRestaurantsNotifierProvider =
    StateNotifierProvider<FavoriteRestaurantNotifier, List<String>>((ref) {
  return FavoriteRestaurantNotifier();
});

// Toggle event favorite
class FavoriteEventNotifier extends StateNotifier<List<String>> {
  FavoriteEventNotifier() : super([]);

  void toggle(String eventId) {
    if (state.contains(eventId)) {
      state = state.where((id) => id != eventId).toList();
    } else {
      state = [...state, eventId];
    }
  }

  void add(String eventId) {
    if (!state.contains(eventId)) {
      state = [...state, eventId];
    }
  }

  void remove(String eventId) {
    state = state.where((id) => id != eventId).toList();
  }
}

final favoriteEventsNotifierProvider =
    StateNotifierProvider<FavoriteEventNotifier, List<String>>((ref) {
  return FavoriteEventNotifier();
});

// Mock login function
Future<User> mockLogin({required String email, String? password, String? phoneNumber}) async {
  await Future.delayed(const Duration(seconds: 1));
  
  return User(
    id: 'user_${DateTime.now().millisecondsSinceEpoch}',
    email: email,
    phoneNumber: phoneNumber,
    displayName: email.split('@')[0],
    userType: UserType.local,
    membershipTier: MembershipTier.free,
    createdAt: DateTime.now(),
  );
}

// Mock logout function
Future<void> mockLogout() async {
  await Future.delayed(const Duration(milliseconds: 500));
}
