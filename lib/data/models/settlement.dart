class Settlement {
  const Settlement({
    required this.id,
    required this.tripId,
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    required this.currencyCode,
    this.completedAt,
  });

  final String id;
  final String tripId;
  final String fromUserId;
  final String toUserId;
  final double amount;
  final String currencyCode;
  final DateTime? completedAt;

  bool get isCompleted => completedAt != null;

  Settlement copyWith({
    String? id,
    String? tripId,
    String? fromUserId,
    String? toUserId,
    double? amount,
    String? currencyCode,
    DateTime? completedAt,
  }) {
    return Settlement(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
