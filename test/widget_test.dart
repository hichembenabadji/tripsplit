import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tripsplit/main.dart';

void main() {
  testWidgets('welcome screen boots', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TripSplitApp()));

    await tester.pumpAndSettle();

    expect(find.text('GET STARTED'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
  });
}
