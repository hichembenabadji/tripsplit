import 'split_method.dart';

class Expense {
  const Expense({
    required this.id,
    required this.tripId,
    required this.title,
    required this.amount,
    required this.currencyCode,
    required this.date,
    required this.paidByUserId,
    required this.participantIds,
    required this.splitMethod,
    this.description,
    this.allocations = const <String, double>{},
    this.isSettled = false,
  });

  final String id;
  final String tripId;
  final String title;
  final String? description;
  final double amount;
  final String currencyCode;
  final DateTime date;
  final String paidByUserId;
  final List<String> participantIds;
  final SplitMethod splitMethod;
  final Map<String, double> allocations;
  final bool isSettled;

  Expense copyWith({
    String? id,
    String? tripId,
    String? title,
    String? description,
    double? amount,
    String? currencyCode,
    DateTime? date,
    String? paidByUserId,
    List<String>? participantIds,
    SplitMethod? splitMethod,
    Map<String, double>? allocations,
    bool? isSettled,
  }) {
    return Expense(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      date: date ?? this.date,
      paidByUserId: paidByUserId ?? this.paidByUserId,
      participantIds: participantIds ?? this.participantIds,
      splitMethod: splitMethod ?? this.splitMethod,
      allocations: allocations ?? this.allocations,
      isSettled: isSettled ?? this.isSettled,
    );
  }
}
