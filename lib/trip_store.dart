import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'auth_service.dart';

final DateTime kTripSplitToday = DateTime(2026, 7, 16);

enum TripStatus { inProgress, upcoming, settled }

enum TripSplitType {
  equally('Equally'),
  custom('Custom'),
  percent('Percent');

  const TripSplitType(this.label);

  final String label;
}

enum ExpenseSplitType {
  equally('Equally'),
  custom('Custom'),
  percent('Percent'),
  fixed('Fixed');

  const ExpenseSplitType(this.label);

  final String label;
}

class TripParticipant {
  const TripParticipant({
    required this.name,
    required this.initials,
    this.isCurrentUser = false,
  });

  final String name;
  final String initials;
  final bool isCurrentUser;

  String get dashboardLabel => isCurrentUser ? 'ME' : initials;
}

class TripExpense {
  const TripExpense({
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.splitType,
    required this.referenceCode,
    this.beneficiaries = const <TripParticipant>[],
  });

  final String title;
  final double amount;
  final TripParticipant paidBy;
  final ExpenseSplitType splitType;
  final String referenceCode;
  final List<TripParticipant> beneficiaries;
}

class AppUserProfile {
  const AppUserProfile({
    required this.firstName,
    this.lastName,
    required this.email,
    this.password,
    this.profileImageBytes,
    this.profileImageUrl,
    required this.memberSince,
  });

  final String firstName;
  final String? lastName;
  final String email;
  final String? password;
  final Uint8List? profileImageBytes;
  final String? profileImageUrl;
  final DateTime memberSince;

  String get displayName {
    final List<String> parts = <String>[
      firstName.trim(),
      if (lastName != null && lastName!.trim().isNotEmpty) lastName!.trim(),
    ];

    return parts.where((String part) => part.isNotEmpty).join(' ');
  }

  String get initials {
    final List<String> parts = displayName
        .split(RegExp(r'\s+'))
        .where((String token) => token.isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) {
      return 'Y';
    }

    return parts.take(2).map((String token) => token[0]).join().toUpperCase();
  }

  AppUserProfile copyWith({
    String? firstName,
    String? lastName,
    bool clearLastName = false,
    String? email,
    String? password,
    bool clearPassword = false,
    Uint8List? profileImageBytes,
    bool clearProfileImage = false,
    String? profileImageUrl,
    bool clearProfileImageUrl = false,
    DateTime? memberSince,
  }) {
    return AppUserProfile(
      firstName: firstName ?? this.firstName,
      lastName: clearLastName ? null : (lastName ?? this.lastName),
      email: email ?? this.email,
      password: clearPassword ? null : (password ?? this.password),
      profileImageBytes: clearProfileImage
          ? null
          : (profileImageBytes ??
                (this.profileImageBytes == null
                    ? null
                    : Uint8List.fromList(this.profileImageBytes!))),
      profileImageUrl: clearProfileImageUrl
          ? null
          : (profileImageUrl ?? this.profileImageUrl),
      memberSince: memberSince ?? this.memberSince,
    );
  }

  static AppUserProfile seed() {
    return AppUserProfile(
      firstName: 'You',
      email: 'you@example.com',
      memberSince: kTripSplitToday,
    );
  }
}

class TripSummary {
  const TripSummary({
    required this.id,
    required this.title,
    required this.destination,
    required this.total,
    required this.currencyCode,
    required this.currencyName,
    required this.currencySymbol,
    required this.currencyFlag,
    required this.status,
    required this.participants,
    required this.splitType,
    this.yourBalance = 0,
    this.totalSettled = 0,
    this.expenses = const <TripExpense>[],
    this.departureDate,
    this.returnDate,
  });

  final String id;
  final String title;
  final String destination;
  final double total;
  final String currencyCode;
  final String currencyName;
  final String currencySymbol;
  final String currencyFlag;
  final TripStatus status;
  final List<TripParticipant> participants;
  final TripSplitType splitType;
  final double yourBalance;
  final double totalSettled;
  final List<TripExpense> expenses;
  final DateTime? departureDate;
  final DateTime? returnDate;

  String get dateRangeLabel {
    if (departureDate != null && returnDate != null) {
      final DateFormat startFormatter = DateFormat('MMM dd');
      final DateFormat endFormatter = DateFormat('MMM dd, yyyy');
      return '${startFormatter.format(departureDate!)} - '
          '${endFormatter.format(returnDate!)}';
    }

    if (departureDate != null) {
      return 'Starts ${DateFormat('MMM dd, yyyy').format(departureDate!)}';
    }

    if (returnDate != null) {
      return 'Ends ${DateFormat('MMM dd, yyyy').format(returnDate!)}';
    }

    return 'Dates TBD';
  }

  int get memberCount => participants.length;

  TripSummary copyWith({
    String? id,
    String? title,
    String? destination,
    double? total,
    String? currencyCode,
    String? currencyName,
    String? currencySymbol,
    String? currencyFlag,
    TripStatus? status,
    List<TripParticipant>? participants,
    TripSplitType? splitType,
    double? yourBalance,
    double? totalSettled,
    List<TripExpense>? expenses,
    DateTime? departureDate,
    DateTime? returnDate,
  }) {
    return TripSummary(
      id: id ?? this.id,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      total: total ?? this.total,
      currencyCode: currencyCode ?? this.currencyCode,
      currencyName: currencyName ?? this.currencyName,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyFlag: currencyFlag ?? this.currencyFlag,
      status: status ?? this.status,
      participants: participants ?? this.participants,
      splitType: splitType ?? this.splitType,
      yourBalance: yourBalance ?? this.yourBalance,
      totalSettled: totalSettled ?? this.totalSettled,
      expenses: expenses ?? this.expenses,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
    );
  }
}

class TripStore extends ChangeNotifier {
  TripStore()
    : _trips = List<TripSummary>.of(_seedTrips),
      _currentUser = AppUserProfile.seed();

  List<TripSummary> _trips;
  AppUserProfile _currentUser;
  int _nextTripSequence = _seedTrips.length + 1;
  int _nextExpenseSequence = 1000;

  UnmodifiableListView<TripSummary> get trips =>
      UnmodifiableListView<TripSummary>(_trips);
  AppUserProfile get currentUser => _currentUser;

  TripSummary? findTripById(String tripId) {
    for (final TripSummary trip in _trips) {
      if (trip.id == tripId) {
        return trip;
      }
    }

    return null;
  }

  TripExpense? findExpenseByReference({
    required String tripId,
    required String expenseReferenceCode,
  }) {
    final TripSummary? trip = findTripById(tripId);
    if (trip == null) {
      return null;
    }

    for (final TripExpense expense in trip.expenses) {
      if (expense.referenceCode == expenseReferenceCode) {
        return expense;
      }
    }

    return null;
  }

  void addTrip({
    required String title,
    required String destination,
    required String currencyCode,
    required String currencyName,
    required String currencySymbol,
    required String currencyFlag,
    required List<TripParticipant> participants,
    required TripSplitType splitType,
    DateTime? departureDate,
    DateTime? returnDate,
  }) {
    final String trimmedTitle = title.trim();
    final String trimmedDestination = destination.trim();
    final DateTime? normalizedReturnDate =
        departureDate != null &&
            returnDate != null &&
            returnDate.isBefore(departureDate)
        ? departureDate
        : returnDate;

    final TripSummary trip = TripSummary(
      id: 'trip_${_nextTripSequence++}',
      title: trimmedTitle,
      destination: trimmedDestination,
      total: 0,
      currencyCode: currencyCode,
      currencyName: currencyName,
      currencySymbol: currencySymbol,
      currencyFlag: currencyFlag,
      status: _deriveStatus(departureDate, normalizedReturnDate),
      participants: List<TripParticipant>.unmodifiable(participants),
      splitType: splitType,
      departureDate: departureDate,
      returnDate: normalizedReturnDate,
    );

    _trips = <TripSummary>[trip, ..._trips];
    notifyListeners();
  }

  void addExpense({
    required String tripId,
    required String title,
    required double amount,
    required TripParticipant paidBy,
    required ExpenseSplitType splitType,
    required List<TripParticipant> beneficiaries,
  }) {
    final String trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty || amount <= 0) {
      return;
    }

    final TripExpense expense = TripExpense(
      title: trimmedTitle,
      amount: amount,
      paidBy: paidBy,
      splitType: splitType,
      referenceCode: _buildExpenseReference(trimmedTitle),
      beneficiaries: List<TripParticipant>.unmodifiable(beneficiaries),
    );

    _trips = _trips
        .map((TripSummary trip) {
          if (trip.id != tripId) {
            return trip;
          }

          return trip.copyWith(
            total: trip.total + amount,
            expenses: <TripExpense>[expense, ...trip.expenses],
          );
        })
        .toList(growable: false);

    notifyListeners();
  }

  void saveCurrentUserAccount({
    required String firstName,
    String? lastName,
    required String email,
    required String password,
    Uint8List? profileImageBytes,
  }) {
    final String normalizedFirstName = firstName.trim();
    final String normalizedLastName = lastName?.trim() ?? '';
    final String normalizedEmail = email.trim();

    if (normalizedFirstName.isEmpty || normalizedEmail.isEmpty) {
      return;
    }

    _currentUser = _currentUser.copyWith(
      firstName: normalizedFirstName,
      lastName: normalizedLastName,
      clearLastName: normalizedLastName.isEmpty,
      email: normalizedEmail,
      password: password,
      profileImageBytes: profileImageBytes == null
          ? null
          : Uint8List.fromList(profileImageBytes),
      clearProfileImage: profileImageBytes == null,
    );
    notifyListeners();
  }

  void updateCurrentUserProfile({
    required String firstName,
    String? lastName,
    required String email,
    Uint8List? profileImageBytes,
    bool removeProfileImage = false,
  }) {
    final String normalizedFirstName = firstName.trim();
    final String normalizedLastName = lastName?.trim() ?? '';
    final String normalizedEmail = email.trim();

    if (normalizedFirstName.isEmpty || normalizedEmail.isEmpty) {
      return;
    }

    _currentUser = _currentUser.copyWith(
      firstName: normalizedFirstName,
      lastName: normalizedLastName,
      clearLastName: normalizedLastName.isEmpty,
      email: normalizedEmail,
      profileImageBytes: profileImageBytes == null
          ? null
          : Uint8List.fromList(profileImageBytes),
      clearProfileImage: removeProfileImage,
    );
    notifyListeners();
  }

  void syncCurrentUserFromAuth(AppAuthUser user) {
    final _ResolvedUserName resolvedName = _resolveUserName(
      displayName: user.displayName,
      email: user.email,
    );

    _currentUser = _currentUser.copyWith(
      firstName: resolvedName.firstName,
      lastName: resolvedName.lastName,
      clearLastName: resolvedName.lastName == null,
      email: user.email,
      clearPassword: true,
      profileImageUrl: user.photoUrl,
      memberSince: user.creationTime ?? _currentUser.memberSince,
    );
    notifyListeners();
  }

  void resetCurrentUserFromAuth() {
    _currentUser = AppUserProfile.seed();
    notifyListeners();
  }

  TripStatus _deriveStatus(DateTime? departureDate, DateTime? returnDate) {
    if (departureDate == null && returnDate == null) {
      return TripStatus.upcoming;
    }

    final DateTime today = kTripSplitToday;
    final DateTime start = departureDate != null
        ? DateTime(departureDate.year, departureDate.month, departureDate.day)
        : today;
    final DateTime end = returnDate != null
        ? DateTime(returnDate.year, returnDate.month, returnDate.day)
        : start;

    if (today.isBefore(start)) {
      return TripStatus.upcoming;
    }

    if (today.isAfter(end)) {
      return TripStatus.settled;
    }

    return TripStatus.inProgress;
  }

  String _buildExpenseReference(String title) {
    final String normalized = title
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]+'), ' ')
        .trim();
    final List<String> parts = normalized
        .split(RegExp(r'\s+'))
        .where((String token) => token.isNotEmpty)
        .toList(growable: false);

    final String prefix = parts.isEmpty
        ? 'EXP'
        : parts.take(3).map((String token) => token[0]).join().padRight(3, 'X');

    return '$prefix-${_nextExpenseSequence++}';
  }

  static final List<TripSummary> _seedTrips = <TripSummary>[
    TripSummary(
      id: 'trip_london_weekend',
      title: 'London Weekend',
      destination: 'London',
      departureDate: DateTime(2026, 10, 12),
      returnDate: DateTime(2026, 10, 15),
      total: 1450,
      currencyCode: 'EUR',
      currencyName: 'Euro',
      currencySymbol: '€',
      currencyFlag: '🇪🇺',
      status: TripStatus.inProgress,
      participants: <TripParticipant>[
        TripParticipant(name: 'Avery', initials: 'A'),
        TripParticipant(name: 'Jules', initials: 'J'),
        TripParticipant(name: 'Chris', initials: 'C'),
        TripParticipant(name: 'You', initials: 'ME', isCurrentUser: true),
      ],
      splitType: TripSplitType.equally,
      yourBalance: 62.00,
      totalSettled: 120.50,
      expenses: <TripExpense>[
        TripExpense(
          title: 'Dinner at Sketch',
          amount: 624.50,
          paidBy: TripParticipant(name: 'Avery', initials: 'A'),
          splitType: ExpenseSplitType.equally,
          referenceCode: 'SKT-928',
          beneficiaries: <TripParticipant>[
            TripParticipant(name: 'Avery', initials: 'A'),
            TripParticipant(name: 'Jules', initials: 'J'),
            TripParticipant(name: 'Chris', initials: 'C'),
            TripParticipant(name: 'You', initials: 'ME', isCurrentUser: true),
          ],
        ),
        TripExpense(
          title: 'Train Tickets',
          amount: 486.00,
          paidBy: TripParticipant(name: 'Jules', initials: 'J'),
          splitType: ExpenseSplitType.percent,
          referenceCode: 'LNE-4410',
          beneficiaries: <TripParticipant>[
            TripParticipant(name: 'Avery', initials: 'A'),
            TripParticipant(name: 'Jules', initials: 'J'),
            TripParticipant(name: 'Chris', initials: 'C'),
            TripParticipant(name: 'You', initials: 'ME', isCurrentUser: true),
          ],
        ),
        TripExpense(
          title: 'Shared Drinks',
          amount: 339.50,
          paidBy: TripParticipant(name: 'Chris', initials: 'C'),
          splitType: ExpenseSplitType.equally,
          referenceCode: 'SHR-1120',
          beneficiaries: <TripParticipant>[
            TripParticipant(name: 'Avery', initials: 'A'),
            TripParticipant(name: 'Jules', initials: 'J'),
            TripParticipant(name: 'Chris', initials: 'C'),
            TripParticipant(name: 'You', initials: 'ME', isCurrentUser: true),
          ],
        ),
      ],
    ),
    TripSummary(
      id: 'trip_kyoto_blossoms',
      title: 'Kyoto Blossoms',
      destination: 'Kyoto',
      departureDate: DateTime(2026, 4, 2),
      returnDate: DateTime(2026, 4, 10),
      total: 320.40,
      currencyCode: 'EUR',
      currencyName: 'Euro',
      currencySymbol: '€',
      currencyFlag: '🇪🇺',
      status: TripStatus.upcoming,
      participants: <TripParticipant>[
        TripParticipant(name: 'Maya', initials: 'M'),
        TripParticipant(name: 'Hugo', initials: 'H'),
        TripParticipant(name: 'You', initials: 'ME', isCurrentUser: true),
      ],
      splitType: TripSplitType.equally,
      yourBalance: -18.40,
      totalSettled: 80.00,
      expenses: <TripExpense>[
        TripExpense(
          title: 'Tea Ceremony',
          amount: 120.15,
          paidBy: TripParticipant(name: 'Maya', initials: 'M'),
          splitType: ExpenseSplitType.custom,
          referenceCode: 'TEA-240',
          beneficiaries: <TripParticipant>[
            TripParticipant(name: 'Maya', initials: 'M'),
            TripParticipant(name: 'Hugo', initials: 'H'),
            TripParticipant(name: 'You', initials: 'ME', isCurrentUser: true),
          ],
        ),
        TripExpense(
          title: 'Temple Tickets',
          amount: 88.25,
          paidBy: TripParticipant(name: 'Hugo', initials: 'H'),
          splitType: ExpenseSplitType.equally,
          referenceCode: 'TMP-882',
          beneficiaries: <TripParticipant>[
            TripParticipant(name: 'Maya', initials: 'M'),
            TripParticipant(name: 'Hugo', initials: 'H'),
            TripParticipant(name: 'You', initials: 'ME', isCurrentUser: true),
          ],
        ),
        TripExpense(
          title: 'Sakura Picnic',
          amount: 112.00,
          paidBy: TripParticipant(name: 'You', initials: 'ME'),
          splitType: ExpenseSplitType.equally,
          referenceCode: 'PIC-110',
          beneficiaries: <TripParticipant>[
            TripParticipant(name: 'Maya', initials: 'M'),
            TripParticipant(name: 'Hugo', initials: 'H'),
            TripParticipant(name: 'You', initials: 'ME', isCurrentUser: true),
          ],
        ),
      ],
    ),
    TripSummary(
      id: 'trip_lisbon_surf',
      title: 'Lisbon Surf',
      destination: 'Lisbon',
      departureDate: DateTime(2026, 7, 20),
      returnDate: DateTime(2026, 7, 28),
      total: 2890.15,
      currencyCode: 'EUR',
      currencyName: 'Euro',
      currencySymbol: '€',
      currencyFlag: '🇪🇺',
      status: TripStatus.settled,
      participants: <TripParticipant>[
        TripParticipant(name: 'You', initials: 'ME', isCurrentUser: true),
        TripParticipant(name: 'Sage', initials: 'S'),
        TripParticipant(name: 'Leo', initials: 'L'),
      ],
      splitType: TripSplitType.equally,
      yourBalance: 140.00,
      totalSettled: 870.35,
      expenses: <TripExpense>[
        TripExpense(
          title: 'Villa Rental',
          amount: 1240.00,
          paidBy: TripParticipant(name: 'Sage', initials: 'S'),
          splitType: ExpenseSplitType.equally,
          referenceCode: 'VIL-884',
          beneficiaries: <TripParticipant>[
            TripParticipant(name: 'You', initials: 'ME', isCurrentUser: true),
            TripParticipant(name: 'Sage', initials: 'S'),
            TripParticipant(name: 'Leo', initials: 'L'),
          ],
        ),
        TripExpense(
          title: 'Board Hire',
          amount: 975.15,
          paidBy: TripParticipant(name: 'Leo', initials: 'L'),
          splitType: ExpenseSplitType.custom,
          referenceCode: 'SRF-312',
          beneficiaries: <TripParticipant>[
            TripParticipant(name: 'You', initials: 'ME', isCurrentUser: true),
            TripParticipant(name: 'Sage', initials: 'S'),
            TripParticipant(name: 'Leo', initials: 'L'),
          ],
        ),
        TripExpense(
          title: 'Beach Dinner',
          amount: 675.00,
          paidBy: TripParticipant(name: 'You', initials: 'ME'),
          splitType: ExpenseSplitType.equally,
          referenceCode: 'DIN-675',
          beneficiaries: <TripParticipant>[
            TripParticipant(name: 'You', initials: 'ME', isCurrentUser: true),
            TripParticipant(name: 'Sage', initials: 'S'),
            TripParticipant(name: 'Leo', initials: 'L'),
          ],
        ),
      ],
    ),
  ];
}

class TripStoreScope extends InheritedNotifier<TripStore> {
  const TripStoreScope({
    super.key,
    required TripStore notifier,
    required super.child,
  }) : super(notifier: notifier);

  static TripStore of(BuildContext context) {
    final TripStoreScope? scope = context
        .dependOnInheritedWidgetOfExactType<TripStoreScope>();
    assert(scope != null, 'No TripStoreScope found in context');
    return scope!.notifier!;
  }

  static TripStore read(BuildContext context) {
    final InheritedElement? element = context
        .getElementForInheritedWidgetOfExactType<TripStoreScope>();
    final TripStoreScope? scope = element?.widget as TripStoreScope?;
    assert(scope != null, 'No TripStoreScope found in context');
    return scope!.notifier!;
  }
}

class _ResolvedUserName {
  const _ResolvedUserName({required this.firstName, this.lastName});

  final String firstName;
  final String? lastName;
}

_ResolvedUserName _resolveUserName({
  required String? displayName,
  required String email,
}) {
  final List<String> tokens = (displayName ?? '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((String token) => token.isNotEmpty)
      .toList(growable: false);

  if (tokens.isNotEmpty) {
    final String firstName = tokens.first;
    final String? lastName = tokens.length > 1
        ? tokens.sublist(1).join(' ')
        : null;
    return _ResolvedUserName(firstName: firstName, lastName: lastName);
  }

  final String localPart = email.split('@').first.trim();
  if (localPart.isEmpty) {
    return const _ResolvedUserName(firstName: 'Traveler');
  }

  final List<String> localTokens = localPart
      .split(RegExp(r'[._-]+'))
      .where((String token) => token.isNotEmpty)
      .map(_capitalizeToken)
      .toList(growable: false);

  if (localTokens.isEmpty) {
    return const _ResolvedUserName(firstName: 'Traveler');
  }

  final String firstName = localTokens.first;
  final String? lastName = localTokens.length > 1
      ? localTokens.sublist(1).join(' ')
      : null;

  return _ResolvedUserName(firstName: firstName, lastName: lastName);
}

String _capitalizeToken(String value) {
  if (value.isEmpty) {
    return value;
  }

  return '${value[0].toUpperCase()}${value.substring(1).toLowerCase()}';
}
