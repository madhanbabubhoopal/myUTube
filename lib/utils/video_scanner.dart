import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/video_item.dart';

class VideoScanner {
  static const int _pageSize = 50;

  static const List<String> supportedExtensions = [
    'mp4', 'mkv', 'avi', 'mov', '3gp', 'webm',
  ];

  /// Request storage permissions appropriate for the Android version.
  /// Returns true when at least one relevant permission is granted.
  static Future<bool> requestPermission() async {
    if (!Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }

    // Android 13+: READ_MEDIA_VIDEO (Permission.videos)
    // Android ≤12: READ_EXTERNAL_STORAGE (Permission.storage)
    // Request both — the OS silently ignores inapplicable ones.
    final videoStatus = await Permission.videos.request();
    final storageStatus = await Permission.storage.request();

    if (videoStatus.isPermanentlyDenied && storageStatus.isPermanentlyDenied) {
      return false;
    }

    return videoStatus.isGranted || storageStatus.isGranted;
  }

  /// Scan all videos on the device via photo_manager.
  /// Paginated at [_pageSize] per batch to avoid memory spikes.
  /// [onProgress] is called with (loaded, estimatedTotal).
  static Future<List<VideoItem>> scanAllVideos({
    void Function(int loaded, int total)? onProgress,
  }) async {
    // photo_manager handles the Android 13 permission internally
    final permissionState = await PhotoManager.requestPermissionExtend();
    if (!permissionState.isAuth) {
      return [];
    }

    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      type: RequestType.video,
      filterOption: FilterOptionGroup(
        videoOption: const FilterOption(
          needTitle: true,
          sizeConstraint: SizeConstraint(ignoreSize: true),
          durationConstraint: DurationConstraint(
            min: Duration.zero,
            max: Duration(hours: 24),
          ),
        ),
      ),
    );

    int totalEstimate = 0;
    for (final p in paths) {
      totalEstimate += await p.assetCountAsync;
    }

    final List<VideoItem> allVideos = [];
    int loaded = 0;

    for (final albumPath in paths) {
      final assetCount = await albumPath.assetCountAsync;
      int start = 0;

      while (start < assetCount) {
        final end = (start + _pageSize).clamp(0, assetCount);

        // Use getAssetListRange (not getAssetListPaged) to avoid
        // off-by-one bug on MIUI/Samsung devices.
        final assets = await albumPath.getAssetListRange(
          start: start,
          end: end,
        );

        for (final asset in assets) {
          if (asset.type != AssetType.video) continue;

          final file = await asset.file;
          if (file == null || !file.existsSync()) continue;

          final ext = file.path.split('.').last.toLowerCase();
          if (!supportedExtensions.contains(ext)) continue;

          allVideos.add(VideoItem(
            id: asset.id,
            path: file.path,
            title: VideoItem.cleanTitle(
                asset.title ?? file.path.split('/').last),
            folderName: albumPath.name,
            duration: asset.videoDuration,
            dateAdded: asset.createDateTime,
          ));
        }

        loaded += assets.length;
        onProgress?.call(loaded, totalEstimate);
        start = end;
      }
    }

    return allVideos;
  }
}
