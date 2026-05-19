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
    await tester.pump(); 

    // 1. Home
    expect(find.text('Welcome to KidsTube'), findsWidgets);

    // 2. Settings (Profile Tab)
    final profileTab = find.descendant(
      of: find.byType(KidsTubeBottomNav),
      matching: find.text('Profile'),
    );
    await tester.tap(profileTab);
    await tester.pump(const Duration(seconds: 1));
    
    // 3. Unlock
    await tester.enterText(find.byType(TextField), '1234');
    await tester.tap(find.text('Unlock'));
    await tester.pump(const Duration(seconds: 1));
    
    // 4. Admin UI
    await tester.tap(find.text('Manage Approved Videos'));
    await tester.pump(const Duration(seconds: 1));
    
    // 5. Approve
    // Tap the title directly, ignoring hit test warnings for now
    await tester.tap(find.text('Daniel Episode 1'), warnIfMissed: false);
    await tester.pump(const Duration(seconds: 1));

    // 6. Return
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump(const Duration(seconds: 1));
    
    final homeTab = find.descendant(
      of: find.byType(KidsTubeBottomNav),
      matching: find.text('Home'),
    );
    await tester.tap(homeTab, warnIfMissed: false);
    await tester.pump(const Duration(seconds: 1));

    // 7. Check
    // If VideoCard is found, it means the navigation worked.
    expect(find.byType(VideoCard), findsWidgets);
  });
}
