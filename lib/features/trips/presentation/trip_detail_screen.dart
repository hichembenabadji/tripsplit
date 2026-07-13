import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/repositories/users_repository.dart';
import '../../../shared/widgets/app_screen.dart';
import '../../../shared/widgets/expense_card.dart';
import '../../../shared/widgets/trip_card.dart';
import '../../expenses/application/expenses_controller.dart';
import '../../settlement/application/settlement_providers.dart';
import '../application/trips_controller.dart';

class TripDetailScreen extends ConsumerWidget {
  const TripDetailScreen({required this.tripId, super.key});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripByIdProvider(tripId));
    final users = ref.watch(usersProvider);
    final expenses = ref.watch(expensesByTripProvider(tripId));
    final settlements = ref.watch(tripSettlementSuggestionsProvider(tripId));

    if (trip == null) {
      return const AppScreen(
        title: 'Trip not found',
        child: _DetailPlaceholder(
          message: 'This route is wired, but the requested trip is missing.',
        ),
      );
    }

    final members = users
        .where((user) => trip.memberIds.contains(user.id))
        .toList();

    return AppScreen(
      title: trip.title,
      subtitle:
          'Trip detail is connected to shared cards and settlement logic.',
      bottomAction: Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton(
              onPressed: () =>
                  context.push(AppRoutes.addExpenseLocation(tripId)),
              child: const Text('Add Expense'),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: ElevatedButton(
              onPressed: () =>
                  context.push(AppRoutes.splitDetailsLocation(tripId)),
              child: const Text('Split Details'),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TripCard(trip: trip, members: members),
          const SizedBox(height: AppSpacing.xxl),
          Text('Expenses', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          if (expenses.isEmpty)
            const _DetailPlaceholder(
              message:
                  'Expenses will appear here after the detailed screen build.',
            ),
          for (final expense in expenses) ...<Widget>[
            ExpenseCard(
              expense: expense,
              paidBy: users.firstWhere(
                (user) => user.id == expense.paidByUserId,
              ),
              participants: users
                  .where((user) => expense.participantIds.contains(user.id))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          Text(
            'Suggested settlements',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (settlements.isEmpty)
            const _DetailPlaceholder(message: 'This trip is already balanced.'),
          for (final settlement in settlements) ...<Widget>[
            _DetailPlaceholder(
              message:
                  '${users.firstWhere((user) => user.id == settlement.fromUserId).name} pays ${users.firstWhere((user) => user.id == settlement.toUserId).name}',
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

class _DetailPlaceholder extends StatelessWidget {
  const _DetailPlaceholder({required this.message, this.trailing});

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
