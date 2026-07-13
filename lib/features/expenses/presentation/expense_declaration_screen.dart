import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/models/split_method.dart';
import '../../../shared/widgets/app_screen.dart';
import '../widgets/split_method_badge_row.dart';

class ExpenseDeclarationScreen extends StatelessWidget {
  const ExpenseDeclarationScreen({required this.tripId, super.key});

  final String tripId;

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      title: 'Expense Declaration',
      subtitle: 'Trip id: $tripId',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Expense presentation is scaffolded and ready for the Figma export cleanup pass.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          const SplitMethodBadgeRow(selectedMethod: SplitMethod.equally),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            decoration: const InputDecoration(labelText: 'Expense title'),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(decoration: const InputDecoration(labelText: 'Amount')),
        ],
      ),
    );
  }
}
