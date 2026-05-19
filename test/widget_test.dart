import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidstube/app.dart';
import 'package:kidstube/screens/player_screen.dart';
import 'package:kidstube/providers/video_provider.dart';
import 'package:kidstube/models/video_item.dart';
import 'package:kidstube/widgets/video_card.dart';
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
  List<VideoItem> get visibleVideos {
    final visible = _mockVideos.where((v) => v.isApproved).toList();
    debugPrint('MOCK: visibleVideos count: ${visible.length}');
    for (var v in visible) {
      debugPrint('MOCK: Visible: ${v.title}');
    }
    return visible;
  }

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
      debugPrint('MOCK: Toggled ${videoId} to ${_mockVideos[idx].isApproved}');
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

    // Start App
    await tester.pumpWidget(KidsTubeApp(provider: mockProvider));
    await tester.pumpAndSettle();

    debugPrint('TEST: Initial check');
    expect(find.text('Welcome to KidsTube'), findsOneWidget);
    expect(find.byType(VideoCard), findsOneWidget);

    // Navigate to Settings
    debugPrint('TEST: Tapping Profile');
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    // Enter PIN
    debugPrint('TEST: Entering PIN');
    await tester.enterText(find.byType(TextField), '1234');
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    // Approve Video
    debugPrint('TEST: Tapping Manage Approved Videos');
    await tester.tap(find.text('Manage Approved Videos'));
    await tester.pumpAndSettle();
    
    debugPrint('TEST: Tapping Daniel Episode 1');
    await tester.tap(find.text('Daniel Episode 1'));
    await tester.pumpAndSettle();

    // Back to Home
    debugPrint('TEST: Going back to Home');
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    debugPrint('TEST: Final verification');
    // Verify visibility
    expect(find.byType(VideoCard), findsNWidgets(2));
  });
}
