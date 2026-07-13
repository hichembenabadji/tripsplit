import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/repositories/users_repository.dart';
import '../../../shared/widgets/app_screen.dart';
import '../../trips/application/trips_controller.dart';
import '../application/settlement_providers.dart';

class SettleUpScreen extends ConsumerWidget {
  const SettleUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTrips = ref.watch(activeTripsProvider);
    final trip = activeTrips.isNotEmpty ? activeTrips.first : null;
    final users = ref.watch(usersProvider);
    final settlements = trip == null
        ? const []
        : ref.watch(tripSettlementSuggestionsProvider(trip.id));

    return AppScreen(
      title: 'Settle Up',
      subtitle: 'Settlement flow placeholder backed by the real service layer.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (trip == null)
            const _SettlePlaceholder(
              message: 'There is no active trip to settle yet.',
            )
          else if (settlements.isEmpty)
            const _SettlePlaceholder(
              message: 'This active trip is already balanced.',
            )
          else
            for (final settlement in settlements) ...<Widget>[
              _SettlePlaceholder(
                message:
                    '${users.firstWhere((user) => user.id == settlement.fromUserId).name} pays ${users.firstWhere((user) => user.id == settlement.toUserId).name}',
                trailing:
                    '${settlement.currencyCode} ${settlement.amount.toStringAsFixed(2)}',
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
        ],
      ),
    );
  }
}

class _SettlePlaceholder extends StatelessWidget {
  const _SettlePlaceholder({required this.message, this.trailing});

  final String message;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
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
