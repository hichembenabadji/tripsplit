import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expense.dart';
import '../models/split_method.dart';

abstract class ExpensesRepository {
  Future<List<Expense>> fetchExpenses();

  Future<void> saveExpense(Expense expense);
}

class InMemoryExpensesRepository implements ExpensesRepository {
  InMemoryExpensesRepository();

  final List<Expense> _expenses = <Expense>[
    Expense(
      id: 'expense-dinner',
      tripId: 'trip-london',
      title: 'Dinner at Sketch',
      description: 'Dinner in Mayfair',
      amount: 244.50,
      currencyCode: 'EUR',
      date: DateTime(2026, 10, 13),
      paidByUserId: 'user-alex',
      participantIds: const <String>[
        'user-alex',
        'user-jordan',
        'user-casey',
        'user-sarah',
      ],
      splitMethod: SplitMethod.equally,
    ),
    Expense(
      id: 'expense-train',
      tripId: 'trip-london',
      title: 'Train Tickets',
      amount: 86.00,
      currencyCode: 'EUR',
      date: DateTime(2026, 10, 12),
      paidByUserId: 'user-casey',
      participantIds: const <String>['user-alex', 'user-casey'],
      splitMethod: SplitMethod.fixed,
      allocations: <String, double>{'user-alex': 43.0, 'user-casey': 43.0},
    ),
    Expense(
      id: 'expense-sharedrinks',
      tripId: 'trip-london',
      title: 'Shared Drinks',
      amount: 112.20,
      currencyCode: 'EUR',
      date: DateTime(2026, 10, 14),
      paidByUserId: 'user-casey',
      participantIds: const <String>['user-casey', 'user-jordan', 'user-sarah'],
      splitMethod: SplitMethod.percentage,
      allocations: <String, double>{
        'user-casey': 34,
        'user-jordan': 33,
        'user-sarah': 33,
      },
    ),
    Expense(
      id: 'expense-kyoto-lunch',
      tripId: 'trip-kyoto',
      title: 'Lunch in Gion',
      amount: 74.40,
      currencyCode: 'EUR',
      date: DateTime(2026, 4, 28),
      paidByUserId: 'user-jordan',
      participantIds: const <String>['user-alex', 'user-jordan', 'user-sarah'],
      splitMethod: SplitMethod.equally,
    ),
  ];

  @override
  Future<List<Expense>> fetchExpenses() async {
    return List<Expense>.unmodifiable(_expenses);
  }

  @override
  Future<void> saveExpense(Expense expense) async {
    final index = _expenses.indexWhere((item) => item.id == expense.id);

    if (index == -1) {
      _expenses.add(expense);
      return;
    }

    _expenses[index] = expense;
  }
}

final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) {
  return InMemoryExpensesRepository();
});
