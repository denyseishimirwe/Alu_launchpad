import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/application.dart';
import '../../../shared/models/opportunity.dart';
import '../../student/widgets/empty_state.dart';
import '../../student/widgets/home_skeleton.dart';
import '../providers/founder_providers.dart';
import 'manage_opportunity_screen.dart';

class FounderDashboardScreen extends ConsumerWidget {
  const FounderDashboardScreen({super.key});

  void _openManage(BuildContext context, Opportunity opportunity) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ManageOpportunityScreen(opportunity: opportunity),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupAsync = ref.watch(founderStartupProvider);
    final opportunitiesAsync = ref.watch(founderOpportunitiesProvider);
    final stats = ref.watch(founderDashboardStatsProvider);

    return SafeArea(
      child: startupAsync.when(
        loading: () => const HomeSkeleton(),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load startup',
          message: error.toString(),
        ),
        data: (startup) {
          if (startup == null) {
            return const EmptyState(
              icon: Icons.business_outlined,
              title: 'No startup profile yet',
              message: 'Complete startup setup from the Post tab first.',
            );
          }

          return opportunitiesAsync.when(
            loading: () => const HomeSkeleton(),
            error: (error, _) => EmptyState(
              icon: Icons.error_outline,
              title: 'Could not load postings',
              message: error.toString(),
            ),
            data: (opportunities) {
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(founderOpportunitiesProvider);
                  ref.invalidate(founderApplicationsProvider);
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    Text(
                      startup.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      startup.location ?? 'ALU Startup',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _StatCard(label: 'Applicants', value: '${stats.applicants}'),
                        const SizedBox(width: 12),
                        _StatCard(label: 'Shortlist', value: '${stats.shortlisted}'),
                        const SizedBox(width: 12),
                        _StatCard(label: 'Open roles', value: '${stats.openRoles}'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Your active postings',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 12),
                    if (opportunities.isEmpty)
                      const EmptyState(
                        icon: Icons.post_add_outlined,
                        title: 'No postings yet',
                        message: 'Publish your first opportunity from the Post tab.',
                      )
                    else
                      ...opportunities.map((opportunity) {
                        final applicantCount = ref
                                .watch(founderApplicationsProvider)
                                .value
                                ?.where((item) =>
                                    item.opportunityId == opportunity.id)
                                .length ??
                            0;
                        final shortlistedCount = ref
                                .watch(founderApplicationsProvider)
                                .value
                                ?.where(
                                  (item) =>
                                      item.opportunityId == opportunity.id &&
                                      item.status == ApplicationStatus.shortlisted,
                                )
                                .length ??
                            0;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opportunity.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  if (opportunity.status ==
                                      OpportunityStatus.closed) ...[
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Closed',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Text(
                                    '$applicantCount applicants · $shortlistedCount shortlisted',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          _openManage(context, opportunity),
                                      child: const Text('Manage'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
