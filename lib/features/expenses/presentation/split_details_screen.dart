import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/models/split_method.dart';
import '../../../shared/widgets/app_screen.dart';
import '../widgets/split_method_badge_row.dart';

class SplitDetailsScreen extends StatelessWidget {
  const SplitDetailsScreen({required this.tripId, super.key});

  final String tripId;

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      title: 'Split Details',
      subtitle: 'Shared split widgets are in place for trip $tripId.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'This placeholder exists so the feature route and child widgets are ready before we drop in the exact Figma layout.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          const SplitMethodBadgeRow(selectedMethod: SplitMethod.fixed),
        ],
      ),
    );
  }
}
