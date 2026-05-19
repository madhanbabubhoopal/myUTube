import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidstube/app.dart';
import 'package:kidstube/providers/video_provider.dart';
import 'package:kidstube/models/video_item.dart';
import 'package:kidstube/widgets/video_card.dart';
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

    // 1. Landing Page
    expect(find.text('Welcome to KidsTube'), findsWidgets);

    // 2. Tab to Profile
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    
    // 3. Unlock with PIN
    await tester.enterText(find.byType(TextField), '1234');
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // 4. Open Admin UI
    await tester.tap(find.text('Manage Approved Videos'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    
    // 5. Toggle Daniel Episode 1
    // Instead of text, find by type and check title
    final tiles = tester.widgetList<CheckboxListTile>(find.byType(CheckboxListTile));
    expect(tiles.length, 2);
    
    await tester.tap(find.text('Daniel Episode 1'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // 6. Return Home
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // 7. Success Check
    expect(find.byType(VideoCard), findsNWidgets(2));
  });
}
