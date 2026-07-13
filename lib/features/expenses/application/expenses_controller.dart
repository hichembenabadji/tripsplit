import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/expense.dart';
import '../../../data/repositories/expenses_repository.dart';

class ExpensesController extends AsyncNotifier<List<Expense>> {
  @override
  Future<List<Expense>> build() async {
    return ref.watch(expensesRepositoryProvider).fetchExpenses();
  }

  Future<void> refreshExpenses() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.watch(expensesRepositoryProvider).fetchExpenses(),
    );
  }

  Future<void> saveExpense(Expense expense) async {
    final repository = ref.read(expensesRepositoryProvider);
    await repository.saveExpense(expense);
    await refreshExpenses();
  }
}

final expensesControllerProvider =
    AsyncNotifierProvider<ExpensesController, List<Expense>>(
      ExpensesController.new,
    );

final expensesByTripProvider = Provider.family<List<Expense>, String>((
  ref,
  tripId,
) {
  final expenses = ref
      .watch(expensesControllerProvider)
      .maybeWhen(data: (expenses) => expenses, orElse: () => <Expense>[]);

  return expenses.where((expense) => expense.tripId == tripId).toList();
});
