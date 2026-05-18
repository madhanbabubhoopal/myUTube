import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidstube/app.dart';
import 'package:kidstube/widgets/kidstube_logo.dart';

void main() {
  testWidgets('App starts up and shows logo and navigation', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KidsTubeApp());
    await tester.pumpAndSettle();

    // Verify the logo exists
    expect(find.byType(KidsTubeLogo), findsOneWidget);

    // Verify the app name is visible
    expect(find.text('KidsTube'), findsWidgets);

    // Verify we have bottom navigation items (Home, Clips, Folders, Library, Profile)
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Clips'), findsOneWidget);
  });
}
