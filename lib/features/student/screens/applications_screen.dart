import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/application.dart';
import '../providers/student_providers.dart';
import '../widgets/application_progress_stepper.dart';
import '../widgets/empty_state.dart';
import '../widgets/home_skeleton.dart';

enum ApplicationTab { applied, inReview, accepted, all }

class ApplicationsScreen extends ConsumerStatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  ConsumerState<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends ConsumerState<ApplicationsScreen> {
  ApplicationTab _tab = ApplicationTab.all;

  List<Application> _filter(List<Application> applications) {
    switch (_tab) {
      case ApplicationTab.applied:
        return applications
            .where((item) => item.status == ApplicationStatus.applied)
            .toList();
      case ApplicationTab.inReview:
        return applications
            .where(
              (item) =>
                  item.status == ApplicationStatus.review ||
                  item.status == ApplicationStatus.shortlisted,
            )
            .toList();
      case ApplicationTab.accepted:
        return applications
            .where((item) => item.status == ApplicationStatus.accepted)
            .toList();
      case ApplicationTab.all:
        return applications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final applicationsAsync = ref.watch(studentApplicationsProvider);

    return SafeArea(
      child: applicationsAsync.when(
        loading: () => const HomeSkeleton(),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load applications',
          message: error.toString(),
        ),
        data: (applications) {
          final filtered = _filter(applications);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  'My Applications',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _TabChip(
                      label: 'Applied',
                      selected: _tab == ApplicationTab.applied,
                      onTap: () =>
                          setState(() => _tab = ApplicationTab.applied),
                    ),
                    _TabChip(
                      label: 'In review',
                      selected: _tab == ApplicationTab.inReview,
                      onTap: () =>
                          setState(() => _tab = ApplicationTab.inReview),
                    ),
                    _TabChip(
                      label: 'Accepted',
                      selected: _tab == ApplicationTab.accepted,
                      onTap: () =>
                          setState(() => _tab = ApplicationTab.accepted),
                    ),
                    _TabChip(
                      label: 'All',
                      selected: _tab == ApplicationTab.all,
                      onTap: () => setState(() => _tab = ApplicationTab.all),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: applications.isEmpty
                    ? const EmptyState(
                        icon: Icons.assignment_outlined,
                        title: 'No applications yet',
                        message:
                            'Apply to opportunities from Home or Explore to track your progress here.',
                      )
                    : filtered.isEmpty
                        ? EmptyState(
                            icon: Icons.filter_list_off,
                            title: 'No applications here',
                            message:
                                'Try another tab to see applications in other stages.',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ApplicationCard(
                                application: filtered[index],
                              ),
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

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primaryLight,
        checkmarkColor: AppColors.primary,
      ),
    );
  }
}

class _ApplicationCard extends ConsumerWidget {
  const _ApplicationCard({required this.application});

  final Application application;

  Future<void> _markRead(WidgetRef ref) async {
    if (!application.hasUpdate) return;
    await ref
        .read(applicationRepositoryProvider)
        .markAsRead(application.id);
  }

  Future<void> _withdraw(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw application?'),
        content: const Text(
          'This will remove your application for this role.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(applicationRepositoryProvider).withdraw(application.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application withdrawn.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not withdraw application.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        onTap: () => _markRead(ref),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.opportunityTitle,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          application.startupName,
                          style:
                              const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (application.hasUpdate)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'New update',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ApplicationProgressStepper(status: application.status),
              const SizedBox(height: 12),
              Text(
                'Status: ${application.status.label}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (application.status == ApplicationStatus.applied ||
                  application.status == ApplicationStatus.review) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _withdraw(context, ref),
                    child: const Text(
                      'Withdraw',
                      style: TextStyle(color: AppColors.accent),
                    ),
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
