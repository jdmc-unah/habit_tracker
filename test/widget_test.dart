import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capstone_project/main.dart';
import 'package:capstone_project/providers/auth_provider.dart';
import 'package:capstone_project/providers/settings_provider.dart';
import 'package:capstone_project/providers/habit_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App builds and launches LoginScreen by default', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(
            create: (_) => AuthProvider()..checkAuthSession(),
          ),
          ChangeNotifierProvider(create: (_) => HabitProvider()),
        ],
        child: const HabittApp(),
      ),
    );

    // Wait for the session check to complete
    await tester.pumpAndSettle();

    // Verify that the login screen is displayed (Habitt title and text fields exist)
    expect(find.text('Habitt'), findsOneWidget);
    expect(find.text('Enter Username'), findsOneWidget);
    expect(find.text('Enter Password'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Log In'), findsOneWidget);
  });
}
