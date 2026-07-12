import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/opportunity_categories.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/opportunity.dart';
import '../../auth/providers/auth_providers.dart';
import '../../student/widgets/empty_state.dart';
import '../providers/founder_providers.dart';
import 'startup_setup_screen.dart';

class PostOpportunityScreen extends ConsumerStatefulWidget {
  const PostOpportunityScreen({super.key});

  @override
  ConsumerState<PostOpportunityScreen> createState() =>
      _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends ConsumerState<PostOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hoursController = TextEditingController(text: '10');
  final _skillController = TextEditingController();

  String _category = OpportunityCategories.postOptions.first;
  WorkType _workType = WorkType.remote;
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));
  final List<String> _skills = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _hoursController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isEmpty || _skills.contains(skill)) return;
    setState(() {
      _skills.add(skill);
      _skillController.clear();
    });
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    if (_skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one required skill.')),
      );
      return;
    }

    final profile = ref.read(currentUserProfileProvider).value;
    final startup = ref.read(founderStartupProvider).value;
    if (profile == null || startup == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(founderRepositoryProvider).createOpportunity(
            founder: profile,
            startup: startup,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _category,
            workType: _workType,
            hoursPerWeek: int.parse(_hoursController.text.trim()),
            requiredSkills: _skills,
            deadline: _deadline,
          );

      if (mounted) {
        _titleController.clear();
        _descriptionController.clear();
        _skills.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opportunity published successfully.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not publish opportunity.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final startupAsync = ref.watch(founderStartupProvider);

    return startupAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => EmptyState(
        icon: Icons.error_outline,
        title: 'Could not load startup',
        message: error.toString(),
      ),
      data: (startup) {
        if (startup == null) {
          return StartupSetupScreen(
            onComplete: () => ref.invalidate(founderStartupProvider),
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Post an opportunity',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Publishing as ${startup.name}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Role title'),
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                    ),
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: OpportunityCategories.postOptions
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _category = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Application deadline'),
                    subtitle: Text(
                      '${_deadline.day}/${_deadline.month}/${_deadline.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today_outlined),
                    onTap: _pickDeadline,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Work type',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<WorkType>(
                    segments: const [
                      ButtonSegment(
                        value: WorkType.remote,
                        label: Text('Remote'),
                      ),
                      ButtonSegment(
                        value: WorkType.onCampus,
                        label: Text('On-campus'),
                      ),
                      ButtonSegment(
                        value: WorkType.hybrid,
                        label: Text('Hybrid'),
                      ),
                    ],
                    selected: {_workType},
                    onSelectionChanged: (selection) {
                      setState(() => _workType = selection.first);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _hoursController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Hours per week',
                    ),
                    validator: (value) {
                      final parsed = int.tryParse(value ?? '');
                      if (parsed == null || parsed <= 0) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _skillController,
                          decoration: const InputDecoration(
                            labelText: 'Required skill',
                          ),
                          onSubmitted: (_) => _addSkill(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _addSkill,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _skills
                        .map(
                          (skill) => Chip(
                            label: Text(skill),
                            onDeleted: () =>
                                setState(() => _skills.remove(skill)),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _publish,
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Publish opportunity'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
