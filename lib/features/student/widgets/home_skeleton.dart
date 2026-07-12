import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => const _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _SkeletonBox(width: 180, height: 18),
            SizedBox(height: 8),
            _SkeletonBox(width: 120, height: 14),
            SizedBox(height: 16),
            _SkeletonBox(width: double.infinity, height: 12),
            SizedBox(height: 8),
            _SkeletonBox(width: 220, height: 12),
            SizedBox(height: 16),
            _SkeletonBox(width: double.infinity, height: 48),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardBorder,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
