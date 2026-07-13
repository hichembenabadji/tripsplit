import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/trip.dart';

abstract class TripsRepository {
  Future<List<Trip>> fetchTrips();

  Future<void> saveTrip(Trip trip);
}

class InMemoryTripsRepository implements TripsRepository {
  InMemoryTripsRepository();

  final List<Trip> _trips = <Trip>[
    Trip(
      id: 'trip-london',
      title: 'London Weekend',
      destination: 'London',
      startDate: DateTime(2026, 10, 12),
      endDate: DateTime(2026, 10, 15),
      currencyCode: 'EUR',
      memberIds: const <String>[
        'user-alex',
        'user-jordan',
        'user-casey',
        'user-sarah',
      ],
      totalAmount: 1450.00,
      status: TripStatus.active,
    ),
    Trip(
      id: 'trip-kyoto',
      title: 'Kyoto Blossoms',
      destination: 'Kyoto',
      startDate: DateTime(2026, 4, 2),
      endDate: DateTime(2026, 4, 10),
      currencyCode: 'EUR',
      memberIds: const <String>['user-alex', 'user-jordan', 'user-sarah'],
      totalAmount: 320.40,
      status: TripStatus.active,
    ),
    Trip(
      id: 'trip-lisbon',
      title: 'Lisbon Surf',
      destination: 'Lisbon',
      startDate: DateTime(2026, 7, 20),
      endDate: DateTime(2026, 7, 28),
      currencyCode: 'EUR',
      memberIds: const <String>['user-alex', 'user-casey', 'user-sarah'],
      totalAmount: 2890.15,
      status: TripStatus.settled,
    ),
  ];

  @override
  Future<List<Trip>> fetchTrips() async {
    return List<Trip>.unmodifiable(_trips);
  }

  @override
  Future<void> saveTrip(Trip trip) async {
    final index = _trips.indexWhere((item) => item.id == trip.id);

    if (index == -1) {
      _trips.add(trip);
      return;
    }

    _trips[index] = trip;
  }
}

final tripsRepositoryProvider = Provider<TripsRepository>((ref) {
  return InMemoryTripsRepository();
});
