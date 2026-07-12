import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/opportunity_categories.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/student_providers.dart';
import '../widgets/category_chips.dart';
import '../widgets/empty_state.dart';
import '../widgets/home_skeleton.dart';
import '../widgets/opportunity_card.dart';
import 'opportunity_detail_screen.dart';

class StudentExploreScreen extends ConsumerWidget {
  const StudentExploreScreen({super.key});

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

    return SafeArea(
      child: opportunitiesAsync.when(
        loading: () => const HomeSkeleton(),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load opportunities',
          message: error.toString(),
        ),
        data: (opportunities) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(openOpportunitiesProvider);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Text(
                  'Explore opportunities',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search roles, startups, skills...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: ref.read(studentFiltersProvider.notifier).setSearch,
                ),
                const SizedBox(height: 16),
                CategoryChips(
                  categories: OpportunityCategories.options,
                  selected: filters.category,
                  onSelected: ref.read(studentFiltersProvider.notifier).setCategory,
                ),
                const SizedBox(height: 20),
                if (opportunities.isEmpty)
                  const EmptyState(
                    icon: Icons.travel_explore,
                    title: 'Nothing to explore yet',
                    message: 'Check back soon or try a different filter.',
                  )
                else
                  ...opportunities.map(
                    (opportunity) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: OpportunityCard(
                        opportunity: opportunity,
                        userSkills: profile?.skills ?? const [],
                        onTap: () => _openDetail(context, opportunity.id),
                        showApplyButton: false,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
