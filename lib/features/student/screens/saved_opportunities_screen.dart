import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../providers/student_providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/home_skeleton.dart';
import '../widgets/opportunity_card.dart';
import 'opportunity_detail_screen.dart';

class SavedOpportunitiesScreen extends ConsumerWidget {
  const SavedOpportunitiesScreen({super.key});

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
    final opportunitiesAsync = ref.watch(openOpportunitiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved opportunities'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: opportunitiesAsync.when(
        loading: () => const HomeSkeleton(),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load saved roles',
          message: error.toString(),
        ),
        data: (opportunities) {
          final savedIds = profile?.savedOpportunityIds ?? const [];
          final saved = opportunities
              .where((item) => savedIds.contains(item.id))
              .toList();

          if (saved.isEmpty) {
            return const EmptyState(
              icon: Icons.bookmark_border,
              title: 'No saved opportunities',
              message: 'Tap the bookmark icon on any role to save it here.',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: saved
                .map(
                  (opportunity) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: OpportunityCard(
                      opportunity: opportunity,
                      userSkills: profile?.skills ?? const [],
                      onTap: () => _openDetail(context, opportunity.id),
                      onApply: () => _openDetail(context, opportunity.id),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
