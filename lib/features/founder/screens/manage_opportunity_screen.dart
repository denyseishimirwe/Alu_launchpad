import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/application.dart';
import '../../../shared/models/opportunity.dart';
import '../../student/widgets/application_progress_stepper.dart';
import '../../student/widgets/empty_state.dart';
import '../../student/widgets/home_skeleton.dart';
import '../providers/founder_providers.dart';

class ManageOpportunityScreen extends ConsumerWidget {
  const ManageOpportunityScreen({super.key, required this.opportunity});

  final Opportunity opportunity;

  Future<void> _closePosting(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close posting?'),
        content: const Text(
          'Students will no longer be able to apply to this role.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Close posting'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(founderRepositoryProvider)
          .closeOpportunity(opportunity.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Posting closed.')),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not close posting.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync =
        ref.watch(opportunityApplicationsProvider(opportunity.id));
    final isClosed = opportunity.status == OpportunityStatus.closed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage posting'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!isClosed)
            TextButton(
              onPressed: () => _closePosting(context, ref),
              child: const Text(
                'Close',
                style: TextStyle(color: AppColors.accent),
              ),
            ),
        ],
      ),
      body: applicationsAsync.when(
        loading: () => const HomeSkeleton(),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load applicants',
          message: error.toString(),
        ),
        data: (applications) {
          if (applications.isEmpty) {
            return EmptyState(
              icon: Icons.people_outline,
              title: 'No applicants yet',
              message: 'Students have not applied to ${opportunity.title} yet.',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      opportunity.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  if (isClosed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Closed',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ...applications.map(
                (application) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ManageApplicantCard(
                    application: application,
                    enabled: !isClosed,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ManageApplicantCard extends ConsumerWidget {
  const _ManageApplicantCard({
    required this.application,
    required this.enabled,
  });

  final Application application;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              application.studentName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            ApplicationProgressStepper(status: application.status),
            if (enabled) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  ApplicationStatus.applied,
                  ApplicationStatus.review,
                  ApplicationStatus.shortlisted,
                  ApplicationStatus.accepted,
                ].map((status) {
                  return ChoiceChip(
                    label: Text(status.label),
                    selected: application.status == status,
                    onSelected: (_) {
                      ref.read(founderRepositoryProvider).updateApplicationStatus(
                            application: application,
                            status: status,
                          );
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
