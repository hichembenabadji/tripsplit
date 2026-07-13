import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/expenses/presentation/expense_declaration_screen.dart';
import '../../features/expenses/presentation/split_details_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/settlement/presentation/calculator_screen.dart';
import '../../features/settlement/presentation/settle_up_screen.dart';
import '../../features/trips/presentation/create_trip_screen.dart';
import '../../features/trips/presentation/my_trips_screen.dart';
import '../../features/trips/presentation/trip_detail_screen.dart';
import '../../shared/widgets/tripsplit_shell_scaffold.dart';
import 'app_routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.trips,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return TripsplitShellScaffold(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.calculator,
                builder: (context, state) => const CalculatorScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: AppRoutes.settleUp,
                    builder: (context, state) => const SettleUpScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.trips,
                builder: (context, state) => const MyTripsScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: AppRoutes.createTrip,
                    builder: (context, state) => const CreateTripScreen(),
                  ),
                  GoRoute(
                    path: ':${AppRoutes.tripId}',
                    builder: (context, state) {
                      final tripId = state.pathParameters[AppRoutes.tripId]!;
                      return TripDetailScreen(tripId: tripId);
                    },
                    routes: <RouteBase>[
                      GoRoute(
                        path: AppRoutes.addExpense,
                        builder: (context, state) {
                          final tripId =
                              state.pathParameters[AppRoutes.tripId]!;
                          return ExpenseDeclarationScreen(tripId: tripId);
                        },
                      ),
                      GoRoute(
                        path: AppRoutes.splitDetails,
                        builder: (context, state) {
                          final tripId =
                              state.pathParameters[AppRoutes.tripId]!;
                          return SplitDetailsScreen(tripId: tripId);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
