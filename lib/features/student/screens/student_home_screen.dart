import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/opportunity_categories.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/utils/skill_matcher.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/student_providers.dart';
import '../widgets/category_chips.dart';
import '../widgets/empty_state.dart';
import '../widgets/home_skeleton.dart';
import '../widgets/opportunity_card.dart';
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
                      Text(
                        'Hello, $firstName 👋',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Find meaningful ways to contribute',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
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
                        ...ranked.map(
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
