import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/settlement.dart';
import '../../../data/services/settlement_service.dart';
import '../../expenses/application/expenses_controller.dart';
import '../../trips/application/trips_controller.dart';

final tripBalancesProvider = Provider.family<Map<String, double>, String>((
  ref,
  tripId,
) {
  final trip = ref.watch(tripByIdProvider(tripId));
  if (trip == null) {
    return const <String, double>{};
  }

  final expenses = ref.watch(expensesByTripProvider(tripId));
  return ref
      .watch(settlementServiceProvider)
      .calculateBalances(trip: trip, expenses: expenses);
});

final tripSettlementSuggestionsProvider =
    Provider.family<List<Settlement>, String>((ref, tripId) {
      final trip = ref.watch(tripByIdProvider(tripId));
      if (trip == null) {
        return const <Settlement>[];
      }

      final expenses = ref.watch(expensesByTripProvider(tripId));
      return ref
          .watch(settlementServiceProvider)
          .suggestSettlements(trip: trip, expenses: expenses);
    });
