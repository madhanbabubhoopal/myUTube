import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidstube/app.dart';
import 'package:kidstube/providers/video_provider.dart';
import 'package:kidstube/models/video_item.dart';
import 'package:kidstube/widgets/video_card.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockVideoProvider extends VideoProvider {
  @override
  bool get isLoading => false;
  @override
  bool get isScanning => false;
  
  final List<VideoItem> _mockVideos = [
    VideoItem(
      id: 'demo_1',
      path: '/path/1.mp4',
      title: 'Welcome to KidsTube',
      folderName: 'Playtime',
      duration: const Duration(minutes: 1),
      isApproved: true,
    ),
  ];

  @override
  List<VideoItem> get allVideos => _mockVideos;

  @override
  List<VideoItem> get visibleVideos => _mockVideos.where((v) => v.isApproved).toList();

  @override
  Future<void> init() async {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Landing page shows approved demo video', (WidgetTester tester) async {
    final mockProvider = MockVideoProvider();

    await tester.pumpWidget(KidsTubeApp(provider: mockProvider));
    await tester.pump(); // Start animations
    await tester.pump(const Duration(milliseconds: 500)); // Wait for animations

    // Check for the demo video title
    expect(find.text('Welcome to KidsTube'), findsWidgets);
    expect(find.byType(VideoCard), findsOneWidget);
  });

  testWidgets('Settings page is accessible via Profile tab', (WidgetTester tester) async {
    final mockProvider = MockVideoProvider();

    await tester.pumpWidget(KidsTubeApp(provider: mockProvider));
    await tester.pump();

    // Tap Profile in bottom nav
    await tester.tap(find.text('Profile'));
    await tester.pump(const Duration(milliseconds: 500));

    // Check for PIN entry field
    expect(find.text('Parental Controls'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
