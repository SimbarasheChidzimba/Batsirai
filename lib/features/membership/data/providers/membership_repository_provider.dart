import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/providers/service_providers.dart';
import '../membership_repository.dart';

/// Provider for MembershipRepository
final membershipRepositoryProvider = Provider<MembershipRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MembershipRepository(apiClient);
});
