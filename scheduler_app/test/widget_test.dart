import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nux_scheduler/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('adds an event and shows it on the schedule', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    expect(find.text('Hello!'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Biology');
    await tester.enterText(fields.at(1), 'Chapter 3: Animal Kingdom');
    await tester.enterText(fields.at(2), 'Room 2-168');
    await tester.enterText(fields.at(3), 'Julie Watson');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Biology'), findsOneWidget);
    expect(find.text('09:00'), findsOneWidget);
    expect(find.text('Julie Watson'), findsOneWidget);

    await tester.tap(find.text('Biology'));
    await tester.pumpAndSettle();
    final dialog = find.byType(AlertDialog);
    expect(dialog, findsOneWidget);
    for (final text in ['Chapter 3: Animal Kingdom', 'Room 2-168', 'Julie Watson', '09:00 – 10:00 (1h)']) {
      expect(find.descendant(of: dialog, matching: find.text(text)), findsOneWidget);
    }
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(dialog, findsNothing);

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Biology'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
