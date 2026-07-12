import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../../../shared/models/application.dart';
import '../../../shared/models/opportunity.dart';
import '../../../shared/models/startup.dart';
import '../data/founder_repository.dart';
import '../data/startup_repository.dart';

final startupRepositoryProvider = Provider<StartupRepository>((ref) {
  return StartupRepository();
});

final founderRepositoryProvider = Provider<FounderRepository>((ref) {
  return FounderRepository();
});

final founderStartupProvider = StreamProvider<Startup?>((ref) {
  final profile = ref.watch(currentUserProfileProvider).value;
  if (profile == null) return Stream.value(null);

  return ref.watch(startupRepositoryProvider).watchFounderStartup(profile.uid);
});

final founderOpportunitiesProvider = StreamProvider<List<Opportunity>>((ref) {
  final profile = ref.watch(currentUserProfileProvider).value;
  if (profile == null) return Stream.value(const []);

  return ref
      .watch(founderRepositoryProvider)
      .watchFounderOpportunities(profile.uid);
});

final founderApplicationsProvider = StreamProvider<List<Application>>((ref) {
  final profile = ref.watch(currentUserProfileProvider).value;
  if (profile == null) return Stream.value(const []);

  return ref
      .watch(founderRepositoryProvider)
      .watchFounderApplications(profile.uid);
});

final opportunityApplicationsProvider =
    StreamProvider.family<List<Application>, String>((ref, opportunityId) {
  return ref
      .watch(founderRepositoryProvider)
      .watchOpportunityApplications(opportunityId);
});

class FounderDashboardStats {
  const FounderDashboardStats({
    required this.applicants,
    required this.shortlisted,
    required this.openRoles,
  });

  final int applicants;
  final int shortlisted;
  final int openRoles;
}

final founderDashboardStatsProvider = Provider<FounderDashboardStats>((ref) {
  final opportunities = ref.watch(founderOpportunitiesProvider).value ?? const [];
  final applications = ref.watch(founderApplicationsProvider).value ?? const [];

  return FounderDashboardStats(
    applicants: applications.length,
    shortlisted: applications
        .where((item) => item.status == ApplicationStatus.shortlisted)
        .length,
    openRoles: opportunities
        .where((item) => item.status == OpportunityStatus.open)
        .length,
  );
});
