import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/application.dart';
import '../../student/widgets/application_progress_stepper.dart';
import '../../student/widgets/empty_state.dart';
import '../../student/widgets/home_skeleton.dart';
import '../providers/founder_providers.dart';

class ApplicantsScreen extends ConsumerWidget {
  const ApplicantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(founderApplicationsProvider);

    return SafeArea(
      child: applicationsAsync.when(
        loading: () => const HomeSkeleton(),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load applicants',
          message: error.toString(),
        ),
        data: (applications) {
          if (applications.isEmpty) {
            return const EmptyState(
              icon: Icons.people_outline,
              title: 'No applicants yet',
              message:
                  'When students apply to your postings, they will appear here.',
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Text(
                'Applicants',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 16),
              ...applications.map(
                (application) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ApplicantCard(application: application),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ApplicantCard extends ConsumerWidget {
  const _ApplicantCard({required this.application});

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
            const SizedBox(height: 4),
            Text(
              application.opportunityTitle,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            ApplicationProgressStepper(status: application.status),
            const SizedBox(height: 12),
            Text(
              'Update status',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ApplicationStatus.values
                  .where((status) => status != ApplicationStatus.rejected)
                  .map(
                    (status) => ChoiceChip(
                      label: Text(status.label),
                      selected: application.status == status,
                      onSelected: (_) async {
                        await ref
                            .read(founderRepositoryProvider)
                            .updateApplicationStatus(
                              applicationId: application.id,
                              status: status,
                            );
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                await ref.read(founderRepositoryProvider).updateApplicationStatus(
                      applicationId: application.id,
                      status: ApplicationStatus.rejected,
                    );
              },
              child: const Text(
                'Reject applicant',
                style: TextStyle(color: AppColors.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
