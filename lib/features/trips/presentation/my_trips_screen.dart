import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../data/models/trip.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/users_repository.dart';
import '../application/trips_controller.dart';
import '../widgets/trip_itinerary_card.dart';
import '../widgets/trips_overview_strip.dart';

class MyTripsScreen extends ConsumerWidget {
  const MyTripsScreen({super.key});

  static const _screenBackground = Color(0xFFFDFAF6);
  static const _brandText = Color(0xFF151B2B);
  static const _sectionText = Color(0xFF564338);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsControllerProvider);
    final users = ref.watch(usersProvider);
    final currentUser = ref.watch(currentUserProvider);

    return ColoredBox(
      color: _screenBackground,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            _TripsHeader(currentUser: currentUser),
            Expanded(
              child: tripsAsync.when(
                data: (trips) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'ACTIVE ITINERARIES',
                          style: GoogleFonts.jetBrainsMono(
                            color: _sectionText,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.45,
                            letterSpacing: 1.1.sp,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          'My Trips',
                          style: GoogleFonts.geist(
                            color: _brandText,
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        TripsOverviewStrip(
                          activeTripCount: trips.length,
                          totalOutstanding: 312.45,
                          currencyCode: trips.isEmpty
                              ? 'EUR'
                              : trips.first.currencyCode,
                          youAreOwed: 120.25,
                          youOwe: 47.80,
                        ),
                        SizedBox(height: 24.h),
                        for (final trip in trips) ...<Widget>[
                          TripItineraryCard(
                            trip: trip,
                            currentUserId: currentUser.id,
                            members: _membersForTrip(trip, users),
                            onTap: () =>
                                context.push(AppRoutes.tripLocation(trip.id)),
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ],
                    ),
                  );
                },
                loading: () =>
                    const _InfoPanel(message: 'Loading trip structure...'),
                error: (error, stackTrace) =>
                    _InfoPanel(message: 'Trips failed to load: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<User> _membersForTrip(Trip trip, List<User> users) {
    return users.where((user) => trip.memberIds.contains(user.id)).toList();
  }
}

class _TripsHeader extends StatelessWidget {
  const _TripsHeader({required this.currentUser});

  final User currentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFA58C7F))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Image.asset(
                'assets/icons/plane.png',
                width: 16.w,
                height: 16.w,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 4.w),
              Text(
                'TRIPSPLIT',
                style: GoogleFonts.geist(
                  color: const Color(0xFF151B2B),
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  letterSpacing: -1.sp,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => context.go(AppRoutes.profile),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFA58C7F)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0x0C000000),
                    blurRadius: 2.r,
                    offset: Offset(0, 1.h),
                  ),
                ],
              ),
              padding: EdgeInsets.all(1.w),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Color(0xFFFCE6D8), Color(0xFFE8BFA7)],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  currentUser.name.substring(0, 1).toUpperCase(),
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFF682D00),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF564338)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        message,
        style: GoogleFonts.inter(
          color: const Color(0xFF404758),
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          height: 1.45,
        ),
      ),
    );
  }
}
