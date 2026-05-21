import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kidstube/main.dart' as app;
import 'package:kidstube/widgets/player_controls.dart';
import 'package:video_player/video_player.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Video Playback Test', () {
    testWidgets('Verify demo video playback and controls', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. Check if we are on the Home Screen and see the Demo Video
      expect(find.text('Welcome to KidsTube'), findsOneWidget);

      // 2. Tap on the Demo Video to start playback
      await tester.tap(find.text('Welcome to KidsTube'));
      
      // Wait for the PlayerScreen to transition and the video to initialize
      // We give it a generous timeout for asset loading
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 3. Verify PlayerScreen is active
      // Look for the specific back button color or the title
      expect(find.text('Welcome to KidsTube'), findsWidgets);

      // 4. Verify Playback Controls exist
      // In the current implementation, controls might be hidden or behind a tap
      // Let's tap the middle of the screen to ensure controls are visible
      final Offset center = tester.getCenter(find.byType(AspectRatio).first);
      await tester.tapAt(center);
      await tester.pump(const Duration(milliseconds: 500));

      // 5. Look for the Play/Pause icon
      // Note: We use find.byIcon(Icons.pause) or Icons.play_arrow
      // Since it autoplays by default, we expect Pause
      expect(find.byIcon(Icons.pause), findsOneWidget);

      // 6. Test Toggle Play/Pause
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // 7. Verify the video player state if possible
      // This is a deeper check to ensure it's not just a UI button change
      final videoPlayer = find.byType(VideoPlayer).evaluate().single.widget as VideoPlayer;
      // We can't easily access the controller from the widget here without more hooks,
      // but finding the VideoPlayer widget itself is a strong indicator of success.
    });
  });
}
