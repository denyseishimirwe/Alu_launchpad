import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../../../shared/models/opportunity.dart';
import '../data/application_repository.dart';
import '../data/opportunity_repository.dart';

final opportunityRepositoryProvider = Provider<OpportunityRepository>((ref) {
  return OpportunityRepository();
});

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepository();
});

final openOpportunitiesProvider = StreamProvider((ref) {
  return ref.watch(opportunityRepositoryProvider).watchOpenOpportunities();
});

final opportunityProvider = StreamProvider.family<Opportunity?, String>((ref, id) {
  return ref.watch(opportunityRepositoryProvider).watchOpportunity(id);
});

final studentApplicationsProvider = StreamProvider((ref) {
  final profile = ref.watch(currentUserProfileProvider).value;
  if (profile == null) {
    return Stream.value(const []);
  }

  return ref
      .watch(applicationRepositoryProvider)
      .watchStudentApplications(profile.uid);
});

class StudentFilters {
  const StudentFilters({
    this.searchQuery = '',
    this.category = 'All',
  });

  final String searchQuery;
  final String category;

  StudentFilters copyWith({
    String? searchQuery,
    String? category,
  }) {
    return StudentFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      category: category ?? this.category,
    );
  }
}

class StudentFiltersNotifier extends Notifier<StudentFilters> {
  @override
  StudentFilters build() => const StudentFilters();

  void setSearch(String value) {
    state = state.copyWith(searchQuery: value);
  }

  void setCategory(String value) {
    state = state.copyWith(category: value);
  }
}

final studentFiltersProvider =
    NotifierProvider<StudentFiltersNotifier, StudentFilters>(
  StudentFiltersNotifier.new,
);

final filteredOpportunitiesProvider = Provider((ref) {
  final opportunities = ref.watch(openOpportunitiesProvider);
  final filters = ref.watch(studentFiltersProvider);

  return opportunities.whenData(
    (items) => filterOpportunities(
      opportunities: items,
      searchQuery: filters.searchQuery,
      category: filters.category,
    ),
  );
});
