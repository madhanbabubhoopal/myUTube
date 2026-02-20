import 'dart:io';
import 'package:flutter/material.dart';
import '../models/video_item.dart';

/// Horizontal thumbnail tray that slides up in fullscreen mode.
/// Shows the next 5 videos; swipe down or tap outside to dismiss.
class SwipeVideoTray extends StatelessWidget {
  final List<VideoItem> videos;
  final ValueChanged<VideoItem> onVideoSelected;
  final VoidCallback onDismiss;

  const SwipeVideoTray({
    super.key,
    required this.videos,
    required this.onVideoSelected,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 200) onDismiss();
      },
      child: Container(
        height: 165,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.88),
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 14, bottom: 8),
              child: Text(
                'Up Next',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: videos.length,
                itemBuilder: (context, i) {
                  final v = videos[i];
                  return GestureDetector(
                    onTap: () => onVideoSelected(v),
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: v.thumbnailPath != null
                                  ? Image.file(
                                      File(v.thumbnailPath!),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (_, __, ___) =>
                                          _placeholder(),
                                    )
                                  : _placeholder(),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            v.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: Colors.grey[800],
        child: const Center(
            child: Icon(Icons.movie, color: Colors.white30, size: 28)),
      );
}
