import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/application.dart';

class ApplicationProgressStepper extends StatelessWidget {
  const ApplicationProgressStepper({
    super.key,
    required this.status,
  });

  final ApplicationStatus status;

  static const _steps = [
    ApplicationStatus.applied,
    ApplicationStatus.review,
    ApplicationStatus.shortlisted,
    ApplicationStatus.accepted,
  ];

  @override
  Widget build(BuildContext context) {
    final activeIndex = _activeStepIndex(status);

    return Row(
      children: List.generate(_steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final stepIndex = index ~/ 2;
          final isComplete = stepIndex < activeIndex;
          return Expanded(
            child: Container(
              height: 2,
              color: isComplete ? AppColors.progress : AppColors.cardBorder,
            ),
          );
        }

        final stepIndex = index ~/ 2;
        final step = _steps[stepIndex];
        final isActive = stepIndex <= activeIndex;
        final isCurrent = stepIndex == activeIndex;

        return Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.progress : AppColors.cardBorder,
                border: isCurrent
                    ? Border.all(color: AppColors.progress, width: 3)
                    : null,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              step.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.progress : AppColors.textSecondary,
              ),
            ),
          ],
        );
      }),
    );
  }

  int _activeStepIndex(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return 0;
      case ApplicationStatus.review:
        return 1;
      case ApplicationStatus.shortlisted:
        return 2;
      case ApplicationStatus.accepted:
        return 3;
      case ApplicationStatus.rejected:
        return 1;
    }
  }
}
