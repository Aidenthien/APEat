import 'package:APEat/pages/student/studentHomepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('StudentHomepage displays the correct AppBar title', (WidgetTester tester) async {
    // Build the StudentHomepage widget
    await tester.pumpWidget(
      MaterialApp(
        home: StudentHomepage(
          onOrderNow: () {}, // Providing a dummy callback for the button
        ),
      ),
    );

    // Verify that the AppBar title is displayed correctly
    expect(
      find.byWidgetPredicate(
            (widget) =>
        widget is AppBar &&
            widget.title is Text &&
            (widget.title as Text).data == 'Homepage',
      ),
      findsOneWidget,
    );

    // Verify that the 'Welcome' text is displayed
    expect(
      find.text('Welcome'),
      findsOneWidget,
    );

    // Verify that the 'to' text is displayed
    expect(
      find.text('to'),
      findsOneWidget,
    );

    // Verify that the 'APEat' text is displayed
    expect(
      find.text('APEat'),
      findsOneWidget,
    );

    // Verify that the 'Order Now' button is displayed
    expect(
      find.widgetWithText(ElevatedButton, 'Order Now'),
      findsOneWidget,
    );
  });
}
