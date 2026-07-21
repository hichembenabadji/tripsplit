import 'package:cloud_firestore/cloud_firestore.dart';

import 'trip_store.dart';
import 'user_repository.dart';

class TripRepositoryFailure implements Exception {
  const TripRepositoryFailure(this.message);

  final String message;

  @override
  String toString() => 'TripRepositoryFailure(message: $message)';
}

abstract class TripRepository {
  Stream<List<TripSummary>> streamUserTrips(String userId);

  Stream<List<TripExpense>> streamTripExpenses(
    String tripId, {
    String? currentUserId,
  });

  Future<String> createTrip({
    required String name,
    required String destination,
    DateTime? startDate,
    DateTime? endDate,
    required String currencyCode,
    required String currencySymbol,
    required String createdByUserId,
    required Iterable<String> participantIds,
    TripStatus? status,
  });

  Future<String> addExpense({
    required String tripId,
    required String title,
    required double amount,
    required String paidByUserId,
    required ExpenseSplitType splitType,
    required Iterable<String> beneficiaryIds,
  });

  Future<void> addParticipantByEmail(String tripId, String email);

  Future<void> updateTripStatus(String tripId, TripStatus status);
}

class FirestoreTripRepository implements TripRepository {
  FirestoreTripRepository({
    FirebaseFirestore? firestore,
    UserDirectoryRepository? userDirectoryRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _userDirectoryRepository =
           userDirectoryRepository ?? FirestoreUserDirectoryRepository();

  final FirebaseFirestore _firestore;
  final UserDirectoryRepository _userDirectoryRepository;

  CollectionReference<Map<String, dynamic>> get _trips =>
      _firestore.collection('trips');

  @override
  Stream<List<TripSummary>> streamUserTrips(String userId) {
    final String normalizedUserId = userId.trim();

    return _trips
        .where('participantIds', arrayContains: normalizedUserId)
        .snapshots()
        .asyncMap((QuerySnapshot<Map<String, dynamic>> snapshot) async {
          if (snapshot.docs.isEmpty) {
            return <TripSummary>[];
          }

          final Set<String> participantIds = <String>{};
          for (final QueryDocumentSnapshot<Map<String, dynamic>> tripDoc
              in snapshot.docs) {
            participantIds.addAll(
              _asStringList(tripDoc.data()['participantIds']),
            );
          }

          final Map<String, UserDirectoryEntry> usersById =
              await _userDirectoryRepository.fetchUsersByIds(participantIds);
          final List<_TripSummaryEnvelope> envelopes = await Future.wait(
            snapshot.docs.map(
              (QueryDocumentSnapshot<Map<String, dynamic>> tripDoc) =>
                  _mapTripSummary(
                    tripDoc,
                    usersById: usersById,
                    currentUserId: normalizedUserId,
                  ),
            ),
          );

          envelopes.sort(_compareTripEnvelopes);
          return envelopes
              .map((_TripSummaryEnvelope envelope) => envelope.trip)
              .toList(growable: false);
        })
        .handleError((Object error) {
          if (error is FirebaseException) {
            throw TripRepositoryFailure(
              error.message ?? 'Unable to stream trips right now.',
            );
          }

          throw error;
        });
  }

  @override
  Stream<List<TripExpense>> streamTripExpenses(
    String tripId, {
    String? currentUserId,
  }) {
    return _trips
        .doc(tripId)
        .collection('expenses')
        .snapshots()
        .asyncMap((QuerySnapshot<Map<String, dynamic>> snapshot) async {
          if (snapshot.docs.isEmpty) {
            return <TripExpense>[];
          }

          final Set<String> userIds = <String>{};
          for (final QueryDocumentSnapshot<Map<String, dynamic>> expenseDoc
              in snapshot.docs) {
            final Map<String, dynamic> data = expenseDoc.data();
            userIds.add(_readString(data['paidBy']));
            userIds.addAll(_asStringList(data['beneficiaryIds']));
          }

          final Map<String, UserDirectoryEntry> usersById =
              await _userDirectoryRepository.fetchUsersByIds(userIds);
          final List<_TripExpenseEnvelope> envelopes = snapshot.docs
              .map(
                (QueryDocumentSnapshot<Map<String, dynamic>> expenseDoc) =>
                    _mapTripExpense(
                      expenseDoc,
                      usersById: usersById,
                      currentUserId: currentUserId,
                    ),
              )
              .toList(growable: false);

          envelopes.sort(_compareExpenseEnvelopes);
          return envelopes
              .map((_TripExpenseEnvelope envelope) => envelope.expense)
              .toList(growable: false);
        })
        .handleError((Object error) {
          if (error is FirebaseException) {
            throw TripRepositoryFailure(
              error.message ?? 'Unable to stream trip expenses right now.',
            );
          }

          throw error;
        });
  }

  @override
  Future<String> createTrip({
    required String name,
    required String destination,
    DateTime? startDate,
    DateTime? endDate,
    required String currencyCode,
    required String currencySymbol,
    required String createdByUserId,
    required Iterable<String> participantIds,
    TripStatus? status,
  }) async {
    final String normalizedName = name.trim();
    final String normalizedDestination = destination.trim();
    final String normalizedCreatedByUserId = createdByUserId.trim();
    final List<String> normalizedParticipantIds = participantIds
        .map((String id) => id.trim())
        .where((String id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);

    if (normalizedName.isEmpty || normalizedDestination.isEmpty) {
      throw const TripRepositoryFailure(
        'Trip name and destination are required.',
      );
    }

    if (normalizedCreatedByUserId.isEmpty) {
      throw const TripRepositoryFailure(
        'A valid creator account is required to create a trip.',
      );
    }

    final List<String> finalParticipantIds = <String>{
      normalizedCreatedByUserId,
      ...normalizedParticipantIds,
    }.toList(growable: false);

    final TripStatus resolvedStatus =
        status ?? _deriveTripStatus(startDate: startDate, endDate: endDate);

    try {
      final DocumentReference<Map<String, dynamic>> createdTripRef =
          await _trips.add(<String, Object?>{
            'name': normalizedName,
            'destination': normalizedDestination,
            'startDate': startDate == null
                ? null
                : Timestamp.fromDate(startDate),
            'endDate': endDate == null ? null : Timestamp.fromDate(endDate),
            'currencyCode': currencyCode.trim(),
            'currencySymbol': currencySymbol.trim(),
            'createdBy': normalizedCreatedByUserId,
            'participantIds': finalParticipantIds,
            'status': resolvedStatus.name,
            'createdAt': FieldValue.serverTimestamp(),
          });

      return createdTripRef.id;
    } on FirebaseException catch (error) {
      throw TripRepositoryFailure(
        error.message ?? 'Unable to create the trip right now.',
      );
    }
  }

  @override
  Future<String> addExpense({
    required String tripId,
    required String title,
    required double amount,
    required String paidByUserId,
    required ExpenseSplitType splitType,
    required Iterable<String> beneficiaryIds,
  }) async {
    final String normalizedTripId = tripId.trim();
    final String normalizedTitle = title.trim();
    final String normalizedPaidByUserId = paidByUserId.trim();
    final List<String> normalizedBeneficiaryIds = beneficiaryIds
        .map((String id) => id.trim())
        .where((String id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);

    if (normalizedTripId.isEmpty || normalizedTitle.isEmpty) {
      throw const TripRepositoryFailure('Trip and expense title are required.');
    }

    if (amount <= 0) {
      throw const TripRepositoryFailure(
        'Expense amount must be greater than zero.',
      );
    }

    if (normalizedPaidByUserId.isEmpty) {
      throw const TripRepositoryFailure(
        'A valid payer account is required to add an expense.',
      );
    }

    try {
      final DocumentReference<Map<String, dynamic>> expenseRef = await _trips
          .doc(normalizedTripId)
          .collection('expenses')
          .add(<String, Object>{
            'title': normalizedTitle,
            'amount': amount,
            'paidBy': normalizedPaidByUserId,
            'splitType': splitType.name,
            'beneficiaryIds': normalizedBeneficiaryIds,
            'createdAt': FieldValue.serverTimestamp(),
          });

      return expenseRef.id;
    } on FirebaseException catch (error) {
      throw TripRepositoryFailure(
        error.message ?? 'Unable to add the expense right now.',
      );
    }
  }

  @override
  Future<void> addParticipantByEmail(String tripId, String email) async {
    final String normalizedTripId = tripId.trim();
    final String normalizedEmail = email.trim();

    if (normalizedTripId.isEmpty || normalizedEmail.isEmpty) {
      throw const TripRepositoryFailure(
        'Trip ID and participant email are required.',
      );
    }

    final UserDirectoryEntry? user = await _userDirectoryRepository
        .findUserByEmail(normalizedEmail);
    if (user == null) {
      throw TripRepositoryFailure(
        'No TripSplit account exists for $normalizedEmail.',
      );
    }

    try {
      await _trips.doc(normalizedTripId).update(<String, Object>{
        'participantIds': FieldValue.arrayUnion(<String>[user.userId]),
      });
    } on FirebaseException catch (error) {
      throw TripRepositoryFailure(
        error.message ?? 'Unable to add that participant right now.',
      );
    }
  }

  @override
  Future<void> updateTripStatus(String tripId, TripStatus status) async {
    final String normalizedTripId = tripId.trim();
    if (normalizedTripId.isEmpty) {
      throw const TripRepositoryFailure('A valid trip ID is required.');
    }

    try {
      await _trips.doc(normalizedTripId).update(<String, Object>{
        'status': status.name,
      });
    } on FirebaseException catch (error) {
      throw TripRepositoryFailure(
        error.message ?? 'Unable to update the trip status right now.',
      );
    }
  }

  Future<_TripSummaryEnvelope> _mapTripSummary(
    QueryDocumentSnapshot<Map<String, dynamic>> tripDoc, {
    required Map<String, UserDirectoryEntry> usersById,
    required String currentUserId,
  }) async {
    final Map<String, dynamic> data = tripDoc.data();
    final DateTime? createdAt = _readDateTime(data['createdAt']);
    final DateTime? startDate = _readDateTime(data['startDate']);
    final DateTime? endDate = _readDateTime(data['endDate']);
    final List<String> participantIds = _asStringList(data['participantIds']);

    final QuerySnapshot<Map<String, dynamic>> expenseSnapshot = await tripDoc
        .reference
        .collection('expenses')
        .get();
    final List<_TripExpenseEnvelope> expenseEnvelopes = expenseSnapshot.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> expenseDoc) =>
              _mapTripExpense(
                expenseDoc,
                usersById: usersById,
                currentUserId: currentUserId,
              ),
        )
        .toList(growable: false);
    expenseEnvelopes.sort(_compareExpenseEnvelopes);
    final List<TripExpense> expenses = expenseEnvelopes
        .map((_TripExpenseEnvelope envelope) => envelope.expense)
        .toList(growable: false);

    final double total = expenses.fold<double>(
      0,
      (double sum, TripExpense expense) => sum + expense.amount,
    );

    final TripSummary trip = TripSummary(
      id: tripDoc.id,
      title: _readString(data['name'], fallback: 'Untitled Trip'),
      destination: _readString(data['destination'], fallback: 'Unknown'),
      total: total,
      currencyCode: _readString(data['currencyCode'], fallback: 'EUR'),
      currencyName: _readString(data['currencyCode'], fallback: 'EUR'),
      currencySymbol: _readString(data['currencySymbol'], fallback: '\u20AC'),
      currencyFlag: '',
      status: _parseTripStatus(
        data['status'],
        startDate: startDate,
        endDate: endDate,
      ),
      participants: _buildParticipants(
        participantIds,
        usersById: usersById,
        currentUserId: currentUserId,
      ),
      splitType: _resolveTripSplitType(expenses),
      yourBalance: 0,
      totalSettled: 0,
      expenses: expenses,
      departureDate: startDate,
      returnDate: endDate,
    );

    return _TripSummaryEnvelope(
      trip: trip,
      createdAt: createdAt,
      startDate: startDate,
    );
  }

  _TripExpenseEnvelope _mapTripExpense(
    QueryDocumentSnapshot<Map<String, dynamic>> expenseDoc, {
    required Map<String, UserDirectoryEntry> usersById,
    String? currentUserId,
  }) {
    final Map<String, dynamic> data = expenseDoc.data();
    final DateTime? createdAt = _readDateTime(data['createdAt']);
    final String paidById = _readString(data['paidBy']);
    final List<String> beneficiaryIds = _asStringList(data['beneficiaryIds']);

    return _TripExpenseEnvelope(
      createdAt: createdAt,
      expense: TripExpense(
        title: _readString(data['title'], fallback: 'Untitled Expense'),
        amount: _readDouble(data['amount']),
        paidBy: _participantFromUserId(
          paidById,
          usersById: usersById,
          currentUserId: currentUserId,
        ),
        splitType: _parseExpenseSplitType(data['splitType']),
        referenceCode: _expenseReferenceCode(expenseDoc.id),
        beneficiaries: beneficiaryIds
            .map(
              (String userId) => _participantFromUserId(
                userId,
                usersById: usersById,
                currentUserId: currentUserId,
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  List<TripParticipant> _buildParticipants(
    List<String> participantIds, {
    required Map<String, UserDirectoryEntry> usersById,
    required String currentUserId,
  }) {
    return participantIds
        .map(
          (String userId) => _participantFromUserId(
            userId,
            usersById: usersById,
            currentUserId: currentUserId,
          ),
        )
        .toList(growable: false);
  }

  TripParticipant _participantFromUserId(
    String userId, {
    required Map<String, UserDirectoryEntry> usersById,
    String? currentUserId,
  }) {
    final UserDirectoryEntry? entry = usersById[userId];
    final String displayName = entry?.displayName.trim().isNotEmpty ?? false
        ? entry!.displayName
        : _fallbackParticipantName(userId);

    return TripParticipant(
      name: displayName,
      initials: _initialsForName(displayName),
      isCurrentUser: currentUserId != null && userId == currentUserId,
    );
  }
}

class _TripSummaryEnvelope {
  const _TripSummaryEnvelope({
    required this.trip,
    required this.createdAt,
    required this.startDate,
  });

  final TripSummary trip;
  final DateTime? createdAt;
  final DateTime? startDate;
}

class _TripExpenseEnvelope {
  const _TripExpenseEnvelope({required this.expense, required this.createdAt});

  final TripExpense expense;
  final DateTime? createdAt;
}

int _compareTripEnvelopes(
  _TripSummaryEnvelope left,
  _TripSummaryEnvelope right,
) {
  final DateTime leftSortDate = left.startDate ?? left.createdAt ?? DateTime(0);
  final DateTime rightSortDate =
      right.startDate ?? right.createdAt ?? DateTime(0);
  return rightSortDate.compareTo(leftSortDate);
}

int _compareExpenseEnvelopes(
  _TripExpenseEnvelope left,
  _TripExpenseEnvelope right,
) {
  final DateTime leftSortDate = left.createdAt ?? DateTime(0);
  final DateTime rightSortDate = right.createdAt ?? DateTime(0);
  return rightSortDate.compareTo(leftSortDate);
}

TripStatus _parseTripStatus(
  Object? storedStatus, {
  required DateTime? startDate,
  required DateTime? endDate,
}) {
  final String? statusName = storedStatus as String?;
  for (final TripStatus status in TripStatus.values) {
    if (status.name == statusName) {
      return status;
    }
  }

  return _deriveTripStatus(startDate: startDate, endDate: endDate);
}

ExpenseSplitType _parseExpenseSplitType(Object? storedSplitType) {
  final String? splitTypeName = storedSplitType as String?;
  for (final ExpenseSplitType splitType in ExpenseSplitType.values) {
    if (splitType.name == splitTypeName) {
      return splitType;
    }
  }

  return ExpenseSplitType.equally;
}

TripSplitType _resolveTripSplitType(List<TripExpense> expenses) {
  if (expenses.isEmpty) {
    return TripSplitType.equally;
  }

  for (final TripExpense expense in expenses) {
    if (expense.splitType == ExpenseSplitType.percent) {
      return TripSplitType.percent;
    }
  }

  for (final TripExpense expense in expenses) {
    if (expense.splitType == ExpenseSplitType.custom ||
        expense.splitType == ExpenseSplitType.fixed) {
      return TripSplitType.custom;
    }
  }

  return TripSplitType.equally;
}

TripStatus _deriveTripStatus({
  required DateTime? startDate,
  required DateTime? endDate,
}) {
  if (startDate == null && endDate == null) {
    return TripStatus.upcoming;
  }

  final DateTime today = DateTime.now();
  final DateTime normalizedToday = DateTime(today.year, today.month, today.day);
  final DateTime normalizedStart = startDate == null
      ? normalizedToday
      : DateTime(startDate.year, startDate.month, startDate.day);
  final DateTime normalizedEnd = endDate == null
      ? normalizedStart
      : DateTime(endDate.year, endDate.month, endDate.day);

  if (normalizedToday.isBefore(normalizedStart)) {
    return TripStatus.upcoming;
  }

  if (normalizedToday.isAfter(normalizedEnd)) {
    return TripStatus.settled;
  }

  return TripStatus.inProgress;
}

List<String> _asStringList(Object? value) {
  if (value is Iterable<Object?>) {
    return value
        .map((Object? item) => (item as String? ?? '').trim())
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
  }

  return <String>[];
}

String _readString(Object? value, {String fallback = ''}) {
  final String resolved = (value as String? ?? '').trim();
  return resolved.isEmpty ? fallback : resolved;
}

double _readDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }

  return 0;
}

DateTime? _readDateTime(Object? value) {
  if (value is Timestamp) {
    return value.toDate();
  }

  if (value is DateTime) {
    return value;
  }

  return null;
}

String _fallbackParticipantName(String userId) {
  if (userId.trim().isEmpty) {
    return 'Traveler';
  }

  final String shortId = userId.trim();
  return 'Traveler ${shortId.substring(0, shortId.length < 4 ? shortId.length : 4).toUpperCase()}';
}

String _initialsForName(String name) {
  final List<String> tokens = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((String token) => token.isNotEmpty)
      .toList(growable: false);

  if (tokens.isEmpty) {
    return 'T';
  }

  return tokens.take(2).map((String token) => token[0]).join().toUpperCase();
}

String _expenseReferenceCode(String expenseId) {
  final String normalized = expenseId
      .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
      .toUpperCase();

  if (normalized.isEmpty) {
    return 'EXP-000';
  }

  final String prefix = normalized.length >= 3
      ? normalized.substring(0, 3)
      : normalized.padRight(3, 'X');
  final String suffix = normalized.length >= 3
      ? normalized.substring(normalized.length - 3)
      : normalized.padLeft(3, '0');
  return '$prefix-$suffix';
}
