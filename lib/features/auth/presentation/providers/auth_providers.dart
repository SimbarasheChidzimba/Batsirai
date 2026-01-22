import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/user.dart';
import 'package:batsirai_app/features/auth/data/providers/auth_repository_provider.dart';
import 'package:batsirai_app/features/auth/data/auth_repository.dart';
import 'package:batsirai_app/core/services/providers/service_providers.dart';
import 'package:batsirai_app/core/services/secure_storage_service.dart';

// Current user provider
final currentUserProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier(ref);
});

// Auth notifier to manage authentication state
class AuthNotifier extends StateNotifier<User?> {
  final Ref _ref;
  late final AuthRepository _authRepository;
  late final SecureStorageService _secureStorage;

  AuthNotifier(this._ref) : super(null) {
    _authRepository = _ref.read(authRepositoryProvider);
    _secureStorage = _ref.read(secureStorageProvider);
    _loadUser();
  }

  /// Load user from secure storage on app start
  Future<void> _loadUser() async {
    final isLoggedIn = await _secureStorage.isLoggedIn();
    if (isLoggedIn) {
      // TODO: Fetch user details from API
      // For now, user will be set after login/register
    }
  }

  /// Set user (called after successful login/register)
  void setUser(User user) {
    state = user;
  }

  /// Clear user (logout)
  Future<void> logout() async {
    await _authRepository.logout();
    state = null;
  }
}

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
