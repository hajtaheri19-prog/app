// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chehel_hadith_app/main.dart';

void main() {
  testWidgets('App should load splash and navigate to home',
      (WidgetTester tester) async {
    // Build our app and verify it loads
    await tester.pumpWidget(const ChehelHadithApp());

    // Verify the app starts with the splash screen
    expect(find.text('چهل حدیث'), findsOneWidget);

    // Advance time to allow splash screen timers to complete
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify we are on the home page (looking for header text)
    expect(find.text('چهل حدیث منتخب'), findsOneWidget);
  });
}
