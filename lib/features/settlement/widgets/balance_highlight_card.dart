import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';

class BalanceHighlightCard extends StatelessWidget {
  const BalanceHighlightCard({
    required this.title,
    required this.subtitle,
    required this.totalAmount,
    required this.currencyCode,
    required this.isBalanced,
    super.key,
  });

  final String title;
  final String subtitle;
  final double totalAmount;
  final String currencyCode;
  final bool isBalanced;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.xl),
          Text(
            AppFormatters.currency(totalAmount, currencyCode: currencyCode),
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppColors.primaryDark),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Icon(
                isBalanced ? Icons.check_circle : Icons.timelapse_rounded,
                color: isBalanced ? AppColors.settled : AppColors.active,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                isBalanced ? 'Balanced split' : 'Pending settlements',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isBalanced ? AppColors.settled : AppColors.active,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
