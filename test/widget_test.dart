import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tripsplit/app_theme_controller.dart';
import 'package:tripsplit/main.dart';

Widget _buildTestApp() {
  return TripSplitApp(
    themeController: AppThemeController(AppThemePreference.system),
  );
}

void main() {
  testWidgets('app creates a trip, expense, and expense details view', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1080, 1920);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_buildTestApp());

    await tester.pumpAndSettle();

    expect(find.text('TRIPSPLIT'), findsOneWidget);
    expect(
      find.text('Split trips. Share expenses. Settle fast.'),
      findsOneWidget,
    );
    expect(find.text('GET STARTED'), findsOneWidget);

    await tester.tap(find.text('GET STARTED'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('My Trips'), findsOneWidget);
    expect(find.text('London Weekend'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('dashboard_add_trip_button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create Trip'), findsOneWidget);
    expect(find.text('NEW ITINERARY'), findsOneWidget);
    expect(find.text('PASSENGER LIST'), findsOneWidget);

    final Finder textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'Rome Escape');
    await tester.enterText(textFields.at(1), 'Rome');

    final Finder currencySelector = find.byKey(
      const ValueKey<String>('create_trip_currency_selector'),
    );
    await tester.ensureVisible(currencySelector);
    await tester.tap(currencySelector);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'British Pound');
    await tester.pumpAndSettle();

    await tester.tap(find.text('British Pound').last);
    await tester.pumpAndSettle();

    expect(find.text('GBP | £'), findsOneWidget);

    final Finder createTripButton = find.byKey(
      const ValueKey<String>('create_trip_submit_button'),
    );
    await tester.ensureVisible(createTripButton);
    await tester.tap(createTripButton);
    await tester.pumpAndSettle();

    expect(find.text('My Trips'), findsOneWidget);
    expect(find.text('Rome Escape'), findsOneWidget);
    expect(find.text('Dates TBD'), findsOneWidget);
    expect(find.text('£0.00'), findsOneWidget);
    expect(find.text('Active Trips: 4'), findsOneWidget);

    await tester.tap(find.text('Rome Escape'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('trip_details_screen')),
      findsOneWidget,
    );
    expect(find.text('EXPENSE LEDGER'), findsOneWidget);
    expect(find.text('No expenses yet'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('trip_details_add_expense_button')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('create_expense_screen')),
      findsOneWidget,
    );
    expect(find.text('EXPENSE DECLARATION'), findsOneWidget);
    expect(find.text('CERTIFY EXPENSE'), findsOneWidget);

    final Finder expenseFields = find.byType(TextField);
    await tester.enterText(expenseFields.at(0), 'Taxi to hotel');
    await tester.enterText(expenseFields.at(1), '24');
    await tester.pumpAndSettle();

    final Finder certifyExpenseButton = find.byKey(
      const ValueKey<String>('create_expense_submit_button'),
    );
    await tester.ensureVisible(certifyExpenseButton);
    await tester.tap(certifyExpenseButton);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('trip_details_screen')),
      findsOneWidget,
    );
    expect(find.text('Taxi to hotel'), findsOneWidget);
    expect(find.text('No expenses yet'), findsNothing);

    await tester.tap(find.text('Taxi to hotel'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('expense_details_screen')),
      findsOneWidget,
    );
    expect(find.text('Split Details'), findsOneWidget);
    expect(find.text('Apply Split'), findsOneWidget);
    expect(find.text('TOTAL DECLARED'), findsOneWidget);
    expect(find.text('BALANCED SPLIT'), findsOneWidget);
  });

  testWidgets('calculator tab opens and evaluates a simple expression', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1080, 1920);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('GET STARTED'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('bottom_nav_calculator')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('calculator_screen')),
      findsOneWidget,
    );

    await tester.tap(find.text('7'));
    await tester.tap(find.text('+'));
    await tester.tap(find.text('8'));
    await tester.pumpAndSettle();

    final Text expressionText = tester.widget<Text>(
      find.byKey(const ValueKey<String>('calculator_expression_text')),
    );
    final Text displayText = tester.widget<Text>(
      find.byKey(const ValueKey<String>('calculator_display_text')),
    );
    expect(expressionText.data, '7 + 8');
    expect(displayText.data, '15');

    await tester.tap(find.text('='));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('bottom_nav_trips')));
    await tester.pumpAndSettle();

    expect(find.text('My Trips'), findsOneWidget);
  });

  testWidgets('profile tab opens and can log out to sign in', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1080, 1920);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('GET STARTED'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('bottom_nav_profile')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('profile_screen')),
      findsOneWidget,
    );
    expect(find.text('PASSENGER PROFILE'), findsOneWidget);
    expect(find.text('Default currency'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('profile_logout_button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets(
    'create account saves required data and edit profile can add optional details',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1080, 1920);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);

      final Finder nextButton = find.byKey(
        const ValueKey<String>('create_account_next_button'),
      );
      ElevatedButton nextButtonWidget = tester.widget<ElevatedButton>(
        nextButton,
      );
      expect(nextButtonWidget.onPressed, isNull);

      final Finder accountFields = find.byType(TextField);
      await tester.enterText(accountFields.at(0), 'Avery');
      await tester.enterText(accountFields.at(2), 'avery@trip');
      await tester.enterText(accountFields.at(3), 'topsecret');
      await tester.pumpAndSettle();

      nextButtonWidget = tester.widget<ElevatedButton>(nextButton);
      expect(nextButtonWidget.onPressed, isNull);

      await tester.enterText(accountFields.at(2), 'avery@trip.com');
      await tester.pumpAndSettle();

      nextButtonWidget = tester.widget<ElevatedButton>(nextButton);
      expect(nextButtonWidget.onPressed, isNotNull);

      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      expect(find.text('My Trips'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey<String>('bottom_nav_profile')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('profile_screen')),
        findsOneWidget,
      );
      expect(find.text('Avery'), findsOneWidget);
      expect(find.text('avery@trip.com'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey<String>('profile_edit_button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Choose photo'), findsOneWidget);

      final Finder editFields = find.byType(TextField);
      await tester.enterText(editFields.at(1), 'Stone');
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey<String>('edit_profile_save_button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Avery Stone'), findsOneWidget);
      expect(find.text('Profile updated.'), findsOneWidget);
    },
  );

  testWidgets(
    'trip details settle up button opens the final statement screen',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1080, 1920);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('London Weekend'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const ValueKey<String>('trip_details_settle_up_button')),
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('trip_details_settle_up_button')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('final_settle_up_screen')),
        findsOneWidget,
      );
      expect(find.text('FINAL STATEMENT'), findsOneWidget);
      expect(find.text('READY TO SETTLE'), findsOneWidget);
      expect(find.text('London Weekend'), findsOneWidget);
      expect(find.text('TOTAL OUTSTANDING'), findsOneWidget);
      expect(find.text('SETTLE UP NOW'), findsOneWidget);
    },
  );
}
