import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slc/features/course%20management/screens/addcourse.dart';

void main() {
  group("Add Course Screen Tests", () {
    testWidgets("Empty form shows validation errors",
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AddCourseScreen()));

      // Tap the submit button without filling fields
      await tester.tap(find.byKey(ValueKey('submit_button')));
      await tester.pump();

      // Check for validation error messages
      expect(find.text("Enter course name"), findsOneWidget);
      expect(find.text("Enter course title"), findsOneWidget);
    });

    testWidgets("Valid input allows form submission",
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AddCourseScreen()));

      await tester.enterText(find.byKey(ValueKey('course_name')), "Math 101");
      await tester.enterText(
          find.byKey(ValueKey('course_title')), "Introduction to Math");

      expect(find.text('Mo'), findsOneWidget);
      expect(find.text('We'), findsOneWidget);
      await tester.tap(find.text('Mo'));
      await tester.tap(find.text('We'));
      await tester.pump();

      await tester.tap(find.descendant(
        of: find.byKey(ValueKey('start_time')),
        matching: find.byType(TextButton),
      ));

      await tester.tap(find.byType(TextButton).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(ValueKey('end_time')));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextButton).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(ValueKey('submit_button')));
      await tester.pump();
    });
  });
}
