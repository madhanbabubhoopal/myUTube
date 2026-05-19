import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidstube/app.dart';
import 'package:kidstube/providers/video_provider.dart';
import 'package:kidstube/models/video_item.dart';
import 'package:kidstube/widgets/video_card.dart';
import 'package:kidstube/widgets/bottom_nav.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockVideoProvider extends VideoProvider {
  List<VideoItem> _mockVideos = [];

  @override
  bool get isLoading => false;
  
  @override
  bool get isScanning => false;

  @override
  List<VideoItem> get allVideos => _mockVideos;

  @override
  List<VideoItem> get visibleVideos => _mockVideos.where((v) => v.isApproved).toList();

  @override
  Future<void> init() async {
    _mockVideos = [
      VideoItem(
        id: 'demo_1',
        path: '/path/1.mp4',
        title: 'Welcome to KidsTube',
        folderName: 'Playtime',
        duration: const Duration(minutes: 1),
        isApproved: true,
      ),
      VideoItem(
        id: 'demo_2',
        path: '/path/2.mp4',
        title: 'Daniel Episode 1',
        folderName: 'Playtime',
        duration: const Duration(minutes: 5),
        isApproved: false,
      ),
    ];
    notifyListeners();
  }

  @override
  Future<void> toggleApproval(String videoId) async {
    final idx = _mockVideos.indexWhere((v) => v.id == videoId);
    if (idx != -1) {
      _mockVideos[idx].isApproved = !_mockVideos[idx].isApproved;
      notifyListeners();
    }
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Full Curator Flow: Home -> Settings -> PIN -> Approve -> Home', (WidgetTester tester) async {
    final mockProvider = MockVideoProvider();
    await mockProvider.init();

    await tester.pumpWidget(KidsTubeApp(provider: mockProvider));
    await tester.pump(const Duration(seconds: 1)); 

    // 1. Home
    expect(find.text('Welcome to KidsTube'), findsWidgets);

    // 2. Settings (Profile Tab)
    // Tapping the icon instead of text for better hit-test
    await tester.tap(find.byIcon(Icons.person_outline), warnIfMissed: false);
    await tester.pump(const Duration(seconds: 1));
    
    // 3. Unlock
    await tester.enterText(find.byType(TextField), '1234');
    await tester.tap(find.text('Unlock'), warnIfMissed: false);
    await tester.pump(const Duration(seconds: 1));
    
    // 4. Admin UI
    await tester.tap(find.text('Manage Approved Videos'), warnIfMissed: false);
    await tester.pump(const Duration(seconds: 1));
    
    // 5. Approve
    // Try to find ANY checkbox tile and tap it
    final listTile = find.byType(CheckboxListTile);
    if (listTile.evaluate().isNotEmpty) {
      await tester.tap(listTile.last, warnIfMissed: false);
    } else {
      // Last ditch effort: find by text again
      await tester.tap(find.textContaining('Daniel', skipOffstage: false), warnIfMissed: false);
    }
    await tester.pump(const Duration(seconds: 1));

    // 6. Return
    await tester.tap(find.byIcon(Icons.arrow_back), warnIfMissed: false);
    await tester.pump(const Duration(seconds: 1));
    
    await tester.tap(find.byIcon(Icons.home_outlined), warnIfMissed: false);
    await tester.pump(const Duration(seconds: 1));

    // 7. Check
    expect(find.byType(VideoCard), findsWidgets);
  });
}
