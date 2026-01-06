import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/api/api_client.dart';
import 'auth_repository.dart';

// Provider for the repository
final termsRepositoryProvider = Provider<TermsRepository>((ref) {
  return TermsRepository(ref);
});

// FutureProvider to load the initial state
final termsAcceptedProvider = Provider<bool>((ref) {
  final user = ref.watch(authRepositoryProvider);
  return user?.acceptedTerms ?? false;
});

class TermsRepository {
  final Ref _ref;
  TermsRepository(this._ref);

  Future<bool> hasAcceptedTerms() async {
    // We check the current user state from AuthRepository
    final user = _ref.read(authRepositoryProvider);
    return user?.acceptedTerms ?? false;
  }

  Future<void> acceptTerms() async {
    final apiClient = _ref.read(apiClientProvider);

    // Call backend to update persistence
    await apiClient.client.post('/auth/accept-terms');

    // Refresh auth state to update local AppUser
    await _ref.read(authRepositoryProvider.notifier).refreshUser();
  }
}
