enum TripStatus { active, settled }

class Trip {
  const Trip({
    required this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.currencyCode,
    required this.memberIds,
    required this.totalAmount,
    required this.status,
  });

  final String id;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String currencyCode;
  final List<String> memberIds;
  final double totalAmount;
  final TripStatus status;

  bool get isSettled => status == TripStatus.settled;

  Trip copyWith({
    String? id,
    String? title,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? currencyCode,
    List<String>? memberIds,
    double? totalAmount,
    TripStatus? status,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      currencyCode: currencyCode ?? this.currencyCode,
      memberIds: memberIds ?? this.memberIds,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
    );
  }
}
