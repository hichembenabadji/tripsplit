import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/split_method.dart';

class SplitMethodBadgeRow extends StatelessWidget {
  const SplitMethodBadgeRow({required this.selectedMethod, super.key});

  final SplitMethod selectedMethod;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: SplitMethod.values.map((method) {
        final selected = method == selectedMethod;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.primaryMuted,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outline,
            ),
          ),
          child: Text(
            method.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selected ? AppColors.white : AppColors.mutedInk,
            ),
          ),
        );
      }).toList(),
    );
  }
}
