import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/trip.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/users_repository.dart';
import '../../../shared/widgets/app_screen.dart';
import '../../../shared/widgets/trip_card.dart';
import '../application/trips_controller.dart';
import '../widgets/trips_overview_strip.dart';

class MyTripsScreen extends ConsumerWidget {
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsControllerProvider);
    final users = ref.watch(usersProvider);

    return AppScreen(
      title: 'My Trips',
      subtitle: 'Core trip routes, cards, and reusable patterns are ready.',
      actions: <Widget>[
        IconButton(
          onPressed: () =>
              context.push('${AppRoutes.trips}/${AppRoutes.createTrip}'),
          icon: const Icon(Icons.add_rounded),
        ),
      ],
      bottomAction: ElevatedButton.icon(
        onPressed: () =>
            context.push('${AppRoutes.trips}/${AppRoutes.createTrip}'),
        icon: const Icon(Icons.add_circle_outline_rounded),
        label: const Text('Create Trip'),
      ),
      child: tripsAsync.when(
        data: (trips) {
          final activeTrips = trips
              .where((trip) => trip.status == TripStatus.active)
              .toList();
          final totalOutstanding = activeTrips.fold<double>(
            0,
            (sum, trip) => sum + trip.totalAmount,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TripsOverviewStrip(
                activeTripCount: activeTrips.length,
                totalOutstanding: totalOutstanding,
                currencyCode: trips.isEmpty ? 'EUR' : trips.first.currencyCode,
              ),
              const SizedBox(height: AppSpacing.xxl),
              for (final trip in trips) ...<Widget>[
                TripCard(
                  trip: trip,
                  members: _membersForTrip(trip, users),
                  onTap: () => context.push(AppRoutes.tripLocation(trip.id)),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ],
          );
        },
        loading: () => const _InfoPanel(message: 'Loading trip structure...'),
        error: (error, stackTrace) =>
            _InfoPanel(message: 'Trips failed to load: $error'),
      ),
    );
  }

  List<User> _membersForTrip(Trip trip, List<User> users) {
    return users.where((user) => trip.memberIds.contains(user.id)).toList();
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(message, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}
