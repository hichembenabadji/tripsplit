import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';

class ProfilePreferenceTile extends StatelessWidget {
  const ProfilePreferenceTile({
    required this.icon,
    required this.title,
    super.key,
    this.value,
    this.toggleValue,
  });

  final IconData icon;
  final String title;
  final String? value;
  final bool? toggleValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: AppColors.mutedInk, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
          ),
          if (value != null)
            Text(value!, style: Theme.of(context).textTheme.bodySmall),
          if (toggleValue != null)
            Switch.adaptive(
              value: toggleValue!,
              onChanged: (_) {},
              activeTrackColor: AppColors.primary,
              activeThumbColor: AppColors.white,
            ),
        ],
      ),
    );
  }
}
