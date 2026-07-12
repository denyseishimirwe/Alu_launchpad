import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/application.dart';
import '../../../shared/models/opportunity.dart';
import '../../student/widgets/application_progress_stepper.dart';
import '../../student/widgets/empty_state.dart';
import '../../student/widgets/home_skeleton.dart';
import '../providers/founder_providers.dart';

class ManageOpportunityScreen extends ConsumerWidget {
  const ManageOpportunityScreen({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync =
        ref.watch(opportunityApplicationsProvider(opportunity.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage posting'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
              Text(
                opportunity.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 16),
              ...applications.map(
                (application) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ManageApplicantCard(application: application),
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
  const _ManageApplicantCard({required this.application});

  final Application application;

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
                          applicationId: application.id,
                          status: status,
                        );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
