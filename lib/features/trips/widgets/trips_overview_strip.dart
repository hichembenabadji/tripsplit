import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';

class TripsOverviewStrip extends StatelessWidget {
  const TripsOverviewStrip({
    required this.activeTripCount,
    required this.totalOutstanding,
    required this.currencyCode,
    super.key,
  });

  final int activeTripCount;
  final double totalOutstanding;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Global overview',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.white.withValues(alpha: 0.84),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppFormatters.currency(
              totalOutstanding,
              currencyCode: currencyCode,
            ),
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '$activeTripCount active trips',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.white.withValues(alpha: 0.82),
            ),
          ),
        ],
      ),
    );
  }
}
