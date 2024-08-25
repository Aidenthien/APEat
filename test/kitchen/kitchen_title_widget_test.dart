import 'package:APEat/pages/kitchenStaff/kitchenMenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('KitchenMenu displays the correct AppBar title', (WidgetTester tester) async {
    // Build the StudentHomepage widget
    await tester.pumpWidget(
      const MaterialApp(
        home: KitchenMenu(
          stallName: '', // Providing an empty string for stallName
        ),
      ),
    );

    // Verify that the AppBar title is displayed correctly
    expect(
      find.byWidgetPredicate(
            (widget) =>
        widget is AppBar &&
            widget.title is Text &&
            (widget.title as Text).data == 'Menu',
      ),
      findsOneWidget,
    );
  });
}
