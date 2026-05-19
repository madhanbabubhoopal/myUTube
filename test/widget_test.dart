import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidstube/app.dart';
import 'package:kidstube/screens/player_screen.dart';
import 'package:kidstube/providers/video_provider.dart';
import 'package:kidstube/models/video_item.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockVideoProvider extends VideoProvider {
  bool _mockLoading = false;
  List<VideoItem> _mockVideos = [];

  @override
  bool get isLoading => _mockLoading;
  
  @override
  bool get isScanning => false;

  @override
  List<VideoItem> get allVideos => _mockVideos;

  @override
  List<VideoItem> get visibleVideos => _mockVideos.where((v) => v.isApproved).toList();

  @override
  Future<void> init() async {
    _mockLoading = true;
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
    _mockLoading = false;
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

    // Start App with the mock provider
    await tester.pumpWidget(KidsTubeApp(provider: mockProvider));
    await tester.pump(); // Initial frame

    // Verify initial approved video is visible
    expect(find.text('Welcome to KidsTube'), findsOneWidget);
    expect(find.text('Daniel Episode 1'), findsNothing);

    // Navigate to Settings (Profile tab)
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();

    // Enter PIN
    await tester.enterText(find.byType(TextField), '1234');
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    // Approve Video
    await tester.tap(find.text('Manage Approved Videos'));
    await tester.pumpAndSettle();
    
    // Tap Daniel Episode 1 (it's a CheckboxListTile)
    await tester.tap(find.text('Daniel Episode 1'));
    await tester.pumpAndSettle();

    // Back to Home
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    
    // Tap Home icon in BottomNav
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();

    // Verify visibility
    expect(find.text('Daniel Episode 1'), findsOneWidget);
  });
}
