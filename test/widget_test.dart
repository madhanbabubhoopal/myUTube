import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidstube/app.dart';
import 'package:kidstube/screens/player_screen.dart';
import 'package:kidstube/providers/video_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Full Curator Flow: Home -> Settings -> PIN -> Approve -> Home', (WidgetTester tester) async {
    // 1. Start App
    await tester.pumpWidget(const KidsTubeApp());
    await tester.pumpAndSettle();

    // Verify initial approved video is visible
    expect(find.text('Welcome to KidsTube'), findsOneWidget);
    expect(find.text('Daniel Episode 1'), findsNothing); // Not approved yet

    // 2. Navigate to Settings
    await tester.tap(find.text('Profile')); // Profile/Settings tab
    await tester.pumpAndSettle();

    // Verify PIN Gate is visible
    expect(find.text('Parental Controls'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // 3. Enter PIN '1234'
    await tester.enterText(find.byType(TextField), '1234');
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    // Verify Settings are unlocked
    expect(find.text('Manage Approved Videos'), findsOneWidget);

    // 4. Go to Manage Approved Videos
    await tester.tap(find.text('Manage Approved Videos'));
    await tester.pumpAndSettle();

    // Find Daniel Episode 1 and approve it
    expect(find.text('Daniel Episode 1'), findsOneWidget);
    await tester.tap(find.text('Daniel Episode 1'));
    await tester.pumpAndSettle();

    // 5. Go back to Home
    await tester.tap(find.byIcon(Icons.arrow_back)); // Back to Settings
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home')); // Back to Home tab
    await tester.pumpAndSettle();

    // Verify both videos are now visible
    expect(find.text('Welcome to KidsTube'), findsOneWidget);
    expect(find.text('Daniel Episode 1'), findsOneWidget);

    // 6. Test Player
    await tester.tap(find.text('Welcome to KidsTube'));
    await tester.pumpAndSettle();

    // Verify Player Screen is open (shows video title in AppBar)
    expect(find.text('Welcome to KidsTube'), findsWidgets);
    
    // Verify basic player UI (icons used in PlayerScreen/PlayerControls)
    expect(find.byIcon(Icons.fullscreen), findsOneWidget);
    
    // Test Play/Pause toggle (starts in play mode due to autoplay)
    // The play icon should NOT be visible initially, pause should be.
    expect(find.byIcon(Icons.pause), findsWidgets);
    
    // Tap player area to show controls if they auto-hide
    await tester.tap(find.byType(PlayerScreen));
    await tester.pump();
    
    // Tap pause
    await tester.tap(find.byIcon(Icons.pause).first);
    await tester.pump();
    
    // Now play icon should be visible
    expect(find.byIcon(Icons.play_arrow), findsWidgets);
  });
}
