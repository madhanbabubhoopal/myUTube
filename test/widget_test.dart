import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidstube/app.dart';
import 'package:kidstube/widgets/kidstube_logo.dart';
import 'package:provider/provider.dart';
import 'package:kidstube/providers/video_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockVideoProvider extends VideoProvider {
  @override
  Future<void> init() async {
    // No-op for testing
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App starts up and shows logo and navigation', (WidgetTester tester) async {
    // Build our app using a mock provider to avoid long-running scans
    await tester.pumpWidget(
      ChangeNotifierProvider<VideoProvider>(
        create: (_) => MockVideoProvider()..init(),
        child: const KidsTubeApp(),
      ),
    );
    
    // Pump frames to allow the app to settle
    await tester.pump();

    // Verify the logo exists (using find.byType as it's a CustomPainter widget)
    expect(find.byType(KidsTubeLogo), findsWidgets);

    // Verify the app name is visible in the AppBar
    expect(find.text('KidsTube'), findsWidgets);

    // Verify we have bottom navigation items
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Clips'), findsOneWidget);
  });
}
