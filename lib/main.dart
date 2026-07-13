import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/navigation/app_router.dart';
import 'core/responsive/app_responsive.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: TripSplitApp()));
}

class TripSplitApp extends ConsumerWidget {
  const TripSplitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return ScreenUtilInit(
      designSize: AppResponsive.designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'TripSplit',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          routerConfig: router,
        );
      },
    );
  }
}
