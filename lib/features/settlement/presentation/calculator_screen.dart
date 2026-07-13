import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_screen.dart';
import '../../trips/application/trips_controller.dart';
import '../application/settlement_providers.dart';
import '../widgets/balance_highlight_card.dart';

class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTrips = ref.watch(activeTripsProvider);
    final featuredTrip = activeTrips.isNotEmpty ? activeTrips.first : null;
    final settlements = featuredTrip == null
        ? const []
        : ref.watch(tripSettlementSuggestionsProvider(featuredTrip.id));

    return AppScreen(
      title: 'Calculator',
      subtitle: 'Balance and settlement logic is available app-wide.',
      bottomAction: ElevatedButton(
        onPressed: featuredTrip == null
            ? null
            : () =>
                  context.push('${AppRoutes.calculator}/${AppRoutes.settleUp}'),
        child: const Text('Open Settle Up'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (featuredTrip != null)
            BalanceHighlightCard(
              title: featuredTrip.title,
              subtitle: 'Current trip settlement summary',
              totalAmount: featuredTrip.totalAmount,
              currencyCode: featuredTrip.currencyCode,
              isBalanced: settlements.isEmpty,
            )
          else
            const _SettlementPanel(
              message: 'No active trips yet. Add one from the Trips tab.',
            ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Next settlements',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (settlements.isEmpty)
            const _SettlementPanel(
              message: 'Suggested transfers will appear here.',
            ),
          for (final settlement in settlements) ...<Widget>[
            _SettlementPanel(
              message: '${settlement.fromUserId} -> ${settlement.toUserId}',
              trailing:
                  '${settlement.currencyCode} ${settlement.amount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _SettlementPanel extends StatelessWidget {
  const _SettlementPanel({required this.message, this.trailing});

  final String message;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyLarge),
          ),
          if (trailing != null)
            Text(trailing!, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
