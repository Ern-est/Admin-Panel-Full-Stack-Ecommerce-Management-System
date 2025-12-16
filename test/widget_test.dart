import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:admin_panel/layout/admin_layout.dart';

void main() {
  // List of roles to test
  final roles = ['admin', 'staff'];

  for (var role in roles) {
    testWidgets('AdminLayout renders correctly for role: $role', (
      WidgetTester tester,
    ) async {
      // Pump the widget with the current role
      await tester.pumpWidget(MaterialApp(home: AdminLayout(role: role)));

      // Wait for any async operations (like loading user)
      await tester.pumpAndSettle();

      // Check that Dashboard is always visible
      expect(find.text('Dashboard'), findsOneWidget);

      // Role-specific checks
      if (role == 'admin') {
        // Admin should see more menu items
        expect(find.text('Products'), findsOneWidget);
        expect(find.text('Categories'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);
      } else if (role == 'staff') {
        // Staff should see limited menu items
        expect(find.text('Products'), findsNothing);
        expect(find.text('Categories'), findsNothing);
        expect(find.text('Settings'), findsOneWidget);
      }
    });
  }
}
