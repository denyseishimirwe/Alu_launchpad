import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../../../shared/models/application.dart';
import '../../../shared/models/opportunity.dart';
import '../data/application_repository.dart';
import '../data/notification_repository.dart';
import '../data/opportunity_repository.dart';
import '../data/saved_repository.dart';

final opportunityRepositoryProvider = Provider<OpportunityRepository>((ref) {
  return OpportunityRepository();
});

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepository();
});

final savedRepositoryProvider = Provider<SavedRepository>((ref) {
  return SavedRepository();
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final openOpportunitiesProvider = StreamProvider((ref) {
  return ref.watch(opportunityRepositoryProvider).watchOpenOpportunities();
});

final opportunityProvider = StreamProvider.family<Opportunity?, String>((ref, id) {
  return ref.watch(opportunityRepositoryProvider).watchOpportunity(id);
});

final studentApplicationsProvider = StreamProvider<List<Application>>((ref) {
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
    this.savedOnly = false,
  });

  final String searchQuery;
  final String category;
  final bool savedOnly;

  StudentFilters copyWith({
    String? searchQuery,
    String? category,
    bool? savedOnly,
  }) {
    return StudentFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      category: category ?? this.category,
      savedOnly: savedOnly ?? this.savedOnly,
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
    state = state.copyWith(category: value, savedOnly: false);
  }

  void setSavedOnly(bool value) {
    state = state.copyWith(savedOnly: value, category: 'All');
  }
}

final studentFiltersProvider =
    NotifierProvider<StudentFiltersNotifier, StudentFilters>(
  StudentFiltersNotifier.new,
);

final filteredOpportunitiesProvider = Provider((ref) {
  final opportunities = ref.watch(openOpportunitiesProvider);
  final filters = ref.watch(studentFiltersProvider);
  final profile = ref.watch(currentUserProfileProvider).value;
  final savedIds = profile?.savedOpportunityIds ?? const [];

  return opportunities.whenData(
    (items) {
      var filtered = filterOpportunities(
        opportunities: items,
        searchQuery: filters.searchQuery,
        category: filters.category,
      );
      if (filters.savedOnly) {
        filtered = filtered.where((item) => savedIds.contains(item.id)).toList();
      }
      return filtered;
    },
  );
});

final studentNotificationsProvider = StreamProvider((ref) {
  final profile = ref.watch(currentUserProfileProvider).value;
  if (profile == null) return Stream.value(const []);

  return ref
      .watch(notificationRepositoryProvider)
      .watchNotifications(profile.uid);
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(studentNotificationsProvider).value ?? const [];
  return notifications.where((item) => !item.read).length;
});
