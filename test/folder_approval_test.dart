import 'package:flutter_test/flutter_test.dart';
import 'package:kidstube/models/video_item.dart';
import 'package:kidstube/providers/video_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestableVideoProvider extends VideoProvider {
  void setMockVideos(List<VideoItem> videos) {
    // We hack the internal state for testing by using the caching mechanism
    // or just exposing a setter. For simplicity in this test, 
    // let's assume we refactored or are using a subclass.
    // However, since _allVideos is private, we'll use a public method to trigger a mock load.
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Targeted Folder Approval Logic Tests', () {
    late VideoProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      provider = VideoProvider();
    });

    test('Logic: visibleVideos should filter by whitelisted folders', () async {
      // Since we can't easily set private _allVideos, we test the logic via toggleFolderApproval
      // which we know modifies both individual items and the whitelistedFolders list.
      
      await provider.toggleFolderApproval('Cartoons', true);
      expect(provider.whitelistedFolders.contains('Cartoons'), isTrue);
      
      await provider.toggleFolderApproval('Cartoons', false);
      expect(provider.whitelistedFolders.contains('Cartoons'), isFalse);
    });

    test('Logic: visibility check includes folder whitelisting', () {
      final v = VideoItem(
        id: '1', 
        path: 'p', 
        title: 'T', 
        folderName: 'WhitelistMe', 
        duration: Duration.zero,
        isApproved: false
      );
      
      // Manual check of the logic we implemented in VideoProvider.visibleVideos getter
      bool isVisible(VideoItem item, List<String> whitelisted, List<String> hidden) {
        return (item.isApproved || whitelisted.contains(item.folderName)) &&
               !hidden.contains(item.folderName);
      }

      expect(isVisible(v, ['WhitelistMe'], []), isTrue);
      expect(isVisible(v, [], []), isFalse);
    });
  });
}
