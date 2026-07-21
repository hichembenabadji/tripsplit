import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_routes.dart';
import 'app_theme_controller.dart';
import 'calculator.dart';
import 'create_account_screen.dart';
import 'dashboard_screen.dart';
import 'edit_profile_screen.dart';
import 'profile_screen.dart';
import 'signin_page.dart';
import 'splash_page.dart';
import 'trip_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppThemeController themeController = await AppThemeController.load();
  runApp(TripSplitApp(themeController: themeController));
}

class TripSplitApp extends StatefulWidget {
  const TripSplitApp({super.key, required this.themeController});

  final AppThemeController themeController;

  @override
  State<TripSplitApp> createState() => _TripSplitAppState();
}

class _TripSplitAppState extends State<TripSplitApp> {
  final TripStore _tripStore = TripStore();

  @override
  Widget build(BuildContext context) {
    return AppThemeScope(
      notifier: widget.themeController,
      child: TripStoreScope(
        notifier: _tripStore,
        child: AnimatedBuilder(
          animation: widget.themeController,
          builder: (BuildContext context, Widget? child) {
            return MaterialApp(
              title: 'TripSplit',
              debugShowCheckedModeBanner: false,
              themeMode: widget.themeController.themeMode,
              theme: _buildTheme(
                brightness: Brightness.light,
                appColors: AppColors.light,
              ),
              darkTheme: _buildTheme(
                brightness: Brightness.dark,
                appColors: AppColors.dark,
              ),
              routes: <String, WidgetBuilder>{
                TripSplitRoutes.signIn: (BuildContext context) =>
                    const SignInPage(),
                TripSplitRoutes.createAccount: (BuildContext context) =>
                    const CreateAccountScreen(),
                TripSplitRoutes.dashboard: (BuildContext context) =>
                    const DashboardScreen(),
                TripSplitRoutes.calculator: (BuildContext context) =>
                    const CalculatorScreen(),
                TripSplitRoutes.profile: (BuildContext context) =>
                    const ProfileScreen(),
                TripSplitRoutes.editProfile: (BuildContext context) =>
                    const EditProfileScreen(),
              },
              home: const SplashPage(),
            );
          },
        ),
      ),
    );
  }
}

ThemeData _buildTheme({
  required Brightness brightness,
  required AppColors appColors,
}) {
  final Color primaryColor = appColors.createTrip.orange;
  final Color onPrimaryColor = appColors.shared.white;
  final Color surfaceColor = appColors.shared.cardBackground;
  final Color onSurfaceColor = brightness == Brightness.dark
      ? appColors.profile.textPrimary
      : appColors.dashboard.textPrimary;
  final Color errorColor = appColors.auth.error;

  final ColorScheme colorScheme = ColorScheme(
    brightness: brightness,
    primary: primaryColor,
    onPrimary: onPrimaryColor,
    secondary: appColors.finalSettle.orangeDark,
    onSecondary: appColors.shared.white,
    error: errorColor,
    onError: appColors.shared.white,
    surface: surfaceColor,
    onSurface: onSurfaceColor,
  );

  return ThemeData(
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: appColors.dashboard.background,
    extensions: <ThemeExtension<dynamic>>[appColors],
    splashColor: appColors.shared.overlayWhite12,
    highlightColor: appColors.shared.transparent,
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: appColors.shared.cardBackground,
      modalBackgroundColor: appColors.shared.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      surfaceTintColor: appColors.shared.transparent,
    ),
  );
}
