import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../models/video_item.dart';
import '../providers/video_provider.dart';
import '../widgets/video_card.dart';
import 'player_screen.dart';

/// Groups all videos by folder. Tapping a folder shows its video list.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VideoProvider>();
    final folderMap = provider.videosByFolder;
    final isDark = provider.isDarkMode;
    final folderNames = folderMap.keys.toList()..sort();

    if (folderNames.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
        body: const Center(
          child: Text('No folders found.',
              style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      body: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: folderNames.length,
          itemBuilder: (context, index) {
            final folder = folderNames[index];
            final videos = folderMap[folder]!;
            final isHidden = provider.hiddenFolders.contains(folder);

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                horizontalOffset: 40,
                child: FadeInAnimation(
                  child: ListTile(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _FolderDetailScreen(
                          folderName: folder,
                          videos: videos,
                        ),
                      ),
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        width: 56,
                        height: 40,
                        color: Colors.grey[800],
                        child: const Icon(Icons.folder,
                            color: Colors.white60),
                      ),
                    ),
                    title: Text(
                      folder,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F0F0F),
                      ),
                    ),
                    subtitle: Text(
                      '${videos.length} video${videos.length == 1 ? '' : 's'}'
                      '${isHidden ? '  •  Hidden' : ''}',
                      style: const TextStyle(color: Color(0xFF606060)),
                    ),
                    trailing: Icon(
                      isHidden ? Icons.visibility_off : Icons.chevron_right,
                      color:
                          isHidden ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FolderDetailScreen extends StatelessWidget {
  final String folderName;
  final List<VideoItem> videos;

  const _FolderDetailScreen({
    required this.folderName,
    required this.videos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF0000),
        title: Text(folderName,
            style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: videos.length,
        itemBuilder: (context, index) => VideoCard(
          video: videos[index],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlayerScreen(
                video: videos[index],
                queue: videos,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
