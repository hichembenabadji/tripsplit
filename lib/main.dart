import 'package:flutter/material.dart';

import 'app_routes.dart';
import 'calculator.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'signin_page.dart';
import 'splash_page.dart';
import 'trip_store.dart';

void main() {
  runApp(const TripSplitApp());
}

class TripSplitApp extends StatefulWidget {
  const TripSplitApp({super.key});

  @override
  State<TripSplitApp> createState() => _TripSplitAppState();
}

class _TripSplitAppState extends State<TripSplitApp> {
  final TripStore _tripStore = TripStore();

  @override
  Widget build(BuildContext context) {
    return TripStoreScope(
      notifier: _tripStore,
      child: MaterialApp(
        title: 'TripSplit',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF7A00)),
        ),
        routes: <String, WidgetBuilder>{
          TripSplitRoutes.signIn: (BuildContext context) => const SignInPage(),
          TripSplitRoutes.dashboard: (BuildContext context) =>
              const DashboardScreen(),
          TripSplitRoutes.calculator: (BuildContext context) =>
              const CalculatorScreen(),
          TripSplitRoutes.profile: (BuildContext context) =>
              const ProfileScreen(),
        },
        home: const SplashPage(),
      ),
    );
  }
}
