import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:APEat/pages/adminManagement/adminHomepage.dart';

void main() {
  testWidgets('AdminHomepage displays the correct AppBar title', (WidgetTester tester) async {
    // Build the MockAdminHomepage widget
    await tester.pumpWidget(
      const MaterialApp(
        home: AdminHomepage(),
      ),
    );

    // Verify that the AppBar title of the MockAdminHomepage is displayed correctly
    expect(
      find.byWidgetPredicate(
            (widget) =>
        widget is AppBar &&
            widget.title is Text &&
            (widget.title as Text).data == 'Food Stall List',
      ),
      findsOneWidget,
    );
  });
}