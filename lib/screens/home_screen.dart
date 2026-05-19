import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../models/video_item.dart';
import '../providers/video_provider.dart';
import '../widgets/video_card.dart';
import 'player_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VideoProvider>();
    final videos = provider.visibleVideos;
    final isDark = provider.isDarkMode;
    final bgColor = isDark ? const Color(0xFF0F0F0F) : Colors.white;

    // ── Loading state (first boot, no cache) ──────────────────────────────
    if (provider.isLoading && videos.isEmpty) {
      return Scaffold(
        backgroundColor: bgColor,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF0000)),
        ),
      );
    }

    // ── Permission denied ─────────────────────────────────────────────────
    if (provider.permissionDenied && videos.isEmpty) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.folder_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Storage permission required\nto find your videos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF0000),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => provider.openSettings(),
                  child: const Text('Open App Settings'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => provider.refreshLibrary(),
                  child: const Text('Retry Permission'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Empty library ─────────────────────────────────────────────────────
    if (videos.isEmpty && !provider.isScanning) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off, size: 64, color: Colors.grey),
              const SizedBox(height: 12),
              const Text(
                'No videos found on your device.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF0000),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                onPressed: () => provider.refreshLibrary(),
              ),
            ],
          ),
        ),
      );
    }

    // ── Normal feed ───────────────────────────────────────────────────────
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 44,
                    child: FadeInAnimation(
                      child: VideoCard(
                        video: videos[index],
                        onTap: () => _openPlayer(context, videos[index], videos),
                        onMoreTap: () =>
                            _showMoreMenu(context, videos[index], provider),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Thin scan-progress bar at the top
          if (provider.isScanning)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: provider.scanTotal > 0
                    ? provider.scanProgress / provider.scanTotal
                    : null,
                color: const Color(0xFFFF0000),
                backgroundColor: Colors.red.withOpacity(0.15),
                minHeight: 3,
              ),
            ),
          // ── Version Indicator ─────────────────────────────────────────────
          Positioned(
            bottom: 8,
            right: 8,
            child: Text(
              'v1.0.0-beta',
              style: TextStyle(
                color: Colors.grey.withOpacity(0.4),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openPlayer(
      BuildContext context, VideoItem video, List<VideoItem> queue) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerScreen(video: video, queue: queue),
      ),
    );
  }

  void _showMoreMenu(
      BuildContext context, VideoItem video, VideoProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.folder_off),
              title: Text('Hide folder "${video.folderName}"'),
              onTap: () {
                provider.toggleFolderVisibility(video.folderName);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Video info'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(video.title),
                    content: Text(
                      'Folder: ${video.folderName}\n'
                      'Duration: ${video.formattedDuration}\n'
                      'Path: ${video.path}',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
