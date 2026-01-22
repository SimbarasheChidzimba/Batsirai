import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/membership_repository_provider.dart';
import '../../data/models/membership_tier_model.dart';

/// Provider for fetching membership tiers from API
final membershipTiersProvider = FutureProvider<List<MembershipTierModel>>((ref) async {
  try {
    print('🔄 membershipTiersProvider: Fetching tiers...');
    final repository = ref.watch(membershipRepositoryProvider);
    final tiers = await repository.getMembershipTiers();
    print('✅ membershipTiersProvider: Got ${tiers.length} tiers');
    return tiers;
  } catch (e, stack) {
    print('❌ membershipTiersProvider Error: $e');
    print('   Stack: $stack');
    rethrow;
  }
});
