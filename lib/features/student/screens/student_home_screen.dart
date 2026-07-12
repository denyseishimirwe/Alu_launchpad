import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/opportunity_categories.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/opportunity.dart';
import '../../../shared/utils/skill_matcher.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/student_providers.dart';
import '../widgets/category_chips.dart';
import '../widgets/empty_state.dart';
import '../widgets/home_skeleton.dart';
import '../widgets/opportunity_card.dart';
import 'notifications_screen.dart';
import 'opportunity_detail_screen.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  void _openDetail(BuildContext context, String opportunityId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OpportunityDetailScreen(opportunityId: opportunityId),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider).value;
    final opportunitiesAsync = ref.watch(filteredOpportunitiesProvider);
    final filters = ref.watch(studentFiltersProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final firstName = profile?.fullName.split(' ').first ?? 'there';

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: opportunitiesAsync.when(
              loading: () => const HomeSkeleton(),
              error: (error, _) => EmptyState(
                icon: Icons.error_outline,
                title: 'Could not load opportunities',
                message: error.toString(),
              ),
              data: (opportunities) {
                final ranked = [...opportunities]
                  ..sort((a, b) {
                    final aMatches = countSkillMatches(
                      profile?.skills ?? const [],
                      a.requiredSkills,
                    );
                    final bMatches = countSkillMatches(
                      profile?.skills ?? const [],
                      b.requiredSkills,
                    );
                    return bMatches.compareTo(aMatches);
                  });

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(openOpportunitiesProvider);
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Hello, $firstName 👋',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const NotificationsScreen(),
                              ),
                            ),
                            icon: Badge(
                              isLabelVisible: unreadCount > 0,
                              label: Text('$unreadCount'),
                              child: const Icon(Icons.notifications_outlined),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Find meaningful ways to contribute',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      if (ranked.isNotEmpty) ...[
                        _FeaturedOpportunityCard(
                          opportunity: ranked.first,
                          userSkills: profile?.skills ?? const [],
                          onTap: () => _openDetail(context, ranked.first.id),
                        ),
                        const SizedBox(height: 20),
                      ],
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search for opportunities...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: ref.read(studentFiltersProvider.notifier).setSearch,
                      ),
                      const SizedBox(height: 16),
                      CategoryChips(
                        categories: OpportunityCategories.options,
                        selected: filters.category,
                        onSelected:
                            ref.read(studentFiltersProvider.notifier).setCategory,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Top matches for you',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 12),
                      if (ranked.isEmpty)
                        const EmptyState(
                          icon: Icons.search_off,
                          title: 'No opportunities found',
                          message:
                              'Try another category or search term to discover roles.',
                        )
                      else
                        ...ranked.skip(ranked.isNotEmpty ? 1 : 0).map(
                          (opportunity) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: OpportunityCard(
                              opportunity: opportunity,
                              userSkills: profile?.skills ?? const [],
                              onTap: () => _openDetail(context, opportunity.id),
                              onApply: () => _openDetail(context, opportunity.id),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedOpportunityCard extends StatelessWidget {
  const _FeaturedOpportunityCard({
    required this.opportunity,
    required this.userSkills,
    required this.onTap,
  });

  final Opportunity opportunity;
  final List<String> userSkills;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final matches = countSkillMatches(userSkills, opportunity.requiredSkills);
    final total = opportunity.requiredSkills.length;

    return Card(
      color: AppColors.primary,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Featured for you',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                opportunity.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                opportunity.startupName,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              if (total > 0) ...[
                const SizedBox(height: 12),
                Text(
                  '$matches/$total skills matched',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
