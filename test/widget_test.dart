import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tripsplit/main.dart';

void main() {
  testWidgets('app shell boots', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TripSplitApp()));

    await tester.pumpAndSettle();

    expect(find.text('My Trips'), findsOneWidget);
    expect(find.text('Create Trip'), findsOneWidget);
  });
}
