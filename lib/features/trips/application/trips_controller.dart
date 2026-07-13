import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/trip.dart';
import '../../../data/repositories/trips_repository.dart';

class TripsController extends AsyncNotifier<List<Trip>> {
  @override
  Future<List<Trip>> build() async {
    return ref.watch(tripsRepositoryProvider).fetchTrips();
  }

  Future<void> refreshTrips() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.watch(tripsRepositoryProvider).fetchTrips(),
    );
  }

  Future<void> saveTrip(Trip trip) async {
    final repository = ref.read(tripsRepositoryProvider);
    await repository.saveTrip(trip);
    await refreshTrips();
  }
}

final tripsControllerProvider =
    AsyncNotifierProvider<TripsController, List<Trip>>(TripsController.new);

final tripByIdProvider = Provider.family<Trip?, String>((ref, tripId) {
  final trips = ref
      .watch(tripsControllerProvider)
      .maybeWhen(data: (trips) => trips, orElse: () => <Trip>[]);

  for (final trip in trips) {
    if (trip.id == tripId) {
      return trip;
    }
  }

  return null;
});

final activeTripsProvider = Provider<List<Trip>>((ref) {
  final trips = ref
      .watch(tripsControllerProvider)
      .maybeWhen(data: (trips) => trips, orElse: () => <Trip>[]);
  return trips.where((trip) => trip.status == TripStatus.active).toList();
});
