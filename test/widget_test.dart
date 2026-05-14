// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sieve_herbal_remedies/main.dart';
import 'package:sieve_herbal_remedies/screens/gardens_screen.dart';

void main() {
  testWidgets('App launches and shows brand', (WidgetTester tester) async {
    // Build the app and verify the home screen loads with app branding.
    await tester.pumpWidget(const SieveApp());
    await tester.pumpAndSettle();

    expect(find.text('Sieve'), findsOneWidget);
    expect(find.text('Herbal Remedies'), findsOneWidget);
  });

  testWidgets('Gardens screen selects and clears a garden card',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GardensScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Get Directions'), findsNothing);

    await tester.tap(find.text('Botanical Herb Haven').first);
    await tester.pumpAndSettle();

    expect(find.text('Get Directions'), findsOneWidget);
    expect(find.text('Botanical Herb Haven'), findsWidgets);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('Get Directions'), findsNothing);
  });

  testWidgets('Gardens screen uses launch callback for directions',
      (WidgetTester tester) async {
    final launchedUris = <Uri>[];

    await tester.pumpWidget(
      MaterialApp(
        home: GardensScreen(
          launchUri: (uri) async {
            launchedUris.add(uri);
            return true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('The Healing Nursery').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get Directions'));
    await tester.pumpAndSettle();

    expect(launchedUris.length, 1);
    expect(launchedUris.first.toString(), contains('google.com/maps/search'));
    expect(launchedUris.first.toString(), contains('156%20Herbal%20Way'));
  });

  testWidgets('Gardens screen shows snackbar when map launch fails',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GardensScreen(
          launchUri: (_) async => false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sage & Soil Collective').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get Directions'));
    await tester.pumpAndSettle();

    expect(find.text('Could not open maps on this device.'), findsOneWidget);
  });
}
