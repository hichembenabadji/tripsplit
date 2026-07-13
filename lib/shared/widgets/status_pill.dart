import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';

enum StatusPillTone { active, settled, danger, neutral }

class StatusPill extends StatelessWidget {
  const StatusPill({required this.label, required this.tone, super.key});

  final String label;
  final StatusPillTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsForTone(tone);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: colors.foreground),
      ),
    );
  }

  _StatusPillColors _colorsForTone(StatusPillTone tone) {
    switch (tone) {
      case StatusPillTone.active:
        return const _StatusPillColors(
          background: AppColors.activeSoft,
          foreground: AppColors.primaryDark,
        );
      case StatusPillTone.settled:
        return const _StatusPillColors(
          background: AppColors.settledSoft,
          foreground: AppColors.settled,
        );
      case StatusPillTone.danger:
        return const _StatusPillColors(
          background: AppColors.alertSoft,
          foreground: AppColors.alert,
        );
      case StatusPillTone.neutral:
        return const _StatusPillColors(
          background: AppColors.primaryMuted,
          foreground: AppColors.mutedInk,
        );
    }
  }
}

class _StatusPillColors {
  const _StatusPillColors({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}
