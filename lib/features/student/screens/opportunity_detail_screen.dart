import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/opportunity.dart';
import '../../../shared/utils/skill_matcher.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/student_providers.dart';
import '../widgets/empty_state.dart';

class OpportunityDetailScreen extends ConsumerStatefulWidget {
  const OpportunityDetailScreen({super.key, required this.opportunityId});

  final String opportunityId;

  @override
  ConsumerState<OpportunityDetailScreen> createState() =>
      _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState
    extends ConsumerState<OpportunityDetailScreen> {
  bool _isApplying = false;
  bool _hasApplied = false;
  bool _checkedApplication = false;

  @override
  void initState() {
    super.initState();
    _loadApplicationState();
  }

  Future<void> _loadApplicationState() async {
    final profile = ref.read(currentUserProfileProvider).value;
    if (profile == null) return;

    final hasApplied = await ref.read(applicationRepositoryProvider).hasApplied(
          studentId: profile.uid,
          opportunityId: widget.opportunityId,
        );

    if (mounted) {
      setState(() {
        _hasApplied = hasApplied;
        _checkedApplication = true;
      });
    }
  }

  Future<void> _apply(Opportunity opportunity) async {
    final profile = ref.read(currentUserProfileProvider).value;
    if (profile == null) return;

    setState(() => _isApplying = true);
    try {
      await ref.read(applicationRepositoryProvider).apply(
            opportunity: opportunity,
            student: profile,
          );
      if (mounted) {
        setState(() => _hasApplied = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted successfully.')),
        );
      }
    } on StateError catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('Could not submit your application. Please try again.');
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  Future<void> _toggleSaved(Opportunity opportunity) async {
    final profile = ref.read(currentUserProfileProvider).value;
    if (profile == null) return;

    await ref.read(savedRepositoryProvider).toggleSaved(
          userId: profile.uid,
          opportunityId: opportunity.id,
          currentSaved: profile.savedOpportunityIds,
        );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final opportunityAsync =
        ref.watch(opportunityProvider(widget.opportunityId));
    final profile = ref.watch(currentUserProfileProvider).value;
    final isSaved =
        profile?.savedOpportunityIds.contains(widget.opportunityId) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Opportunity Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          opportunityAsync.maybeWhen(
            data: (opportunity) => opportunity == null
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: () => _toggleSaved(opportunity),
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? AppColors.primary : null,
                    ),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: opportunityAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load opportunity',
          message: error.toString(),
        ),
        data: (opportunity) {
          if (opportunity == null) {
            return const EmptyState(
              icon: Icons.work_off_outlined,
              title: 'Opportunity not found',
              message: 'This role may have been removed or closed.',
            );
          }

          if (opportunity.status == OpportunityStatus.closed) {
            return const EmptyState(
              icon: Icons.lock_outline,
              title: 'Role closed',
              message: 'This opportunity is no longer accepting applications.',
            );
          }

          final matches = countSkillMatches(
            profile?.skills ?? const [],
            opportunity.requiredSkills,
          );
          final total = opportunity.requiredSkills.length;
          final dateFormat = DateFormat('MMM d, yyyy');

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opportunity.title,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        opportunity.startupName,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'Commitment',
                              value: '${opportunity.hoursPerWeek} hrs/week',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Work type',
                              value: opportunity.workType.label,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'About the role',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        opportunity.description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Text(
                            'Required skills',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          if (total > 0) ...[
                            const Spacer(),
                            Text(
                              '$matches/$total skills matched',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: opportunity.requiredSkills
                            .map(
                              (skill) => Chip(
                                label: Text(skill),
                                backgroundColor: AppColors.primaryLight,
                                side: BorderSide.none,
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Deadline: ${dateFormat.format(opportunity.deadline)}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: !_checkedApplication || _isApplying || _hasApplied
                        ? null
                        : () => _apply(opportunity),
                    child: _isApplying
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_hasApplied ? 'Applied' : 'Apply Now'),
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

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
