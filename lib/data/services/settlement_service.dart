import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../models/expense.dart';
import '../models/settlement.dart';
import '../models/split_method.dart';
import '../models/trip.dart';

class SettlementService {
  Map<String, double> calculateBalances({
    required Trip trip,
    required List<Expense> expenses,
  }) {
    final balances = <String, double>{
      for (final memberId in trip.memberIds) memberId: 0,
    };

    for (final expense in expenses.where((item) => item.tripId == trip.id)) {
      balances[expense.paidByUserId] =
          (balances[expense.paidByUserId] ?? 0) + expense.amount;

      final split = _resolveSplitShares(expense);
      for (final entry in split.entries) {
        balances[entry.key] = (balances[entry.key] ?? 0) - entry.value;
      }
    }

    return balances.map((key, value) => MapEntry(key, _roundCurrency(value)));
  }

  List<Settlement> suggestSettlements({
    required Trip trip,
    required List<Expense> expenses,
  }) {
    final balances = calculateBalances(trip: trip, expenses: expenses);
    final creditors = <_BalanceEntry>[];
    final debtors = <_BalanceEntry>[];

    for (final entry in balances.entries) {
      final rounded = _roundCurrency(entry.value);
      if (rounded > 0.01) {
        creditors.add(_BalanceEntry(entry.key, rounded));
      } else if (rounded < -0.01) {
        debtors.add(_BalanceEntry(entry.key, rounded.abs()));
      }
    }

    final settlements = <Settlement>[];
    var creditorIndex = 0;
    var debtorIndex = 0;

    while (creditorIndex < creditors.length && debtorIndex < debtors.length) {
      final creditor = creditors[creditorIndex];
      final debtor = debtors[debtorIndex];
      final amount = _roundCurrency(
        creditor.balance < debtor.balance ? creditor.balance : debtor.balance,
      );

      settlements.add(
        Settlement(
          id: 'settlement-${trip.id}-${settlements.length}',
          tripId: trip.id,
          fromUserId: debtor.userId,
          toUserId: creditor.userId,
          amount: amount,
          currencyCode: trip.currencyCode,
        ),
      );

      creditor.balance = _roundCurrency(creditor.balance - amount);
      debtor.balance = _roundCurrency(debtor.balance - amount);

      if (creditor.balance <= 0.01) {
        creditorIndex++;
      }
      if (debtor.balance <= 0.01) {
        debtorIndex++;
      }
    }

    return settlements;
  }

  double totalTripAmount(List<Expense> expenses, String tripId) {
    final amount = expenses
        .where((expense) => expense.tripId == tripId)
        .fold<double>(0, (sum, expense) => sum + expense.amount);

    return _roundCurrency(amount);
  }

  Map<String, double> _resolveSplitShares(Expense expense) {
    switch (expense.splitMethod) {
      case SplitMethod.equally:
        final participants = expense.participantIds;
        if (participants.isEmpty) {
          return const <String, double>{};
        }

        final share = expense.amount / participants.length;
        return <String, double>{
          for (final participant in participants)
            participant: _roundCurrency(share),
        };
      case SplitMethod.fixed:
        return expense.allocations.map(
          (key, value) => MapEntry(key, _roundCurrency(value)),
        );
      case SplitMethod.percentage:
        return expense.allocations.map(
          (key, value) =>
              MapEntry(key, _roundCurrency(expense.amount * (value / 100))),
        );
    }
  }

  double _roundCurrency(double value) {
    return double.parse(value.toStringAsFixed(2));
  }
}

class _BalanceEntry {
  _BalanceEntry(this.userId, this.balance);

  final String userId;
  double balance;
}

final settlementServiceProvider = Provider<SettlementService>((ref) {
  return SettlementService();
});

final defaultCurrencyProvider = Provider<String>((ref) {
  return AppConstants.defaultCurrencyCode;
});
