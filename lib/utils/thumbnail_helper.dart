import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

class ThumbnailHelper {
  static String? _cacheDir;

  static Future<String> _getCacheDir() async {
    if (_cacheDir != null) return _cacheDir!;
    final appCacheDir = await getApplicationCacheDirectory();
    final dir = Directory('${appCacheDir.path}/thumbnails');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    _cacheDir = dir.path;
    return _cacheDir!;
  }

  static String _hashPath(String path) {
    var hash = 0;
    for (int i = 0; i < path.length; i++) {
      hash = (hash * 31 + path.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return hash.toString();
  }

  /// Generates a thumbnail for a video.
  /// If [videoId] is provided, uses photo_manager (most efficient).
  /// Otherwise fallbacks to path-based generation (if implemented).
  static Future<String?> generateThumbnail(String videoPath, {String? videoId}) async {
    try {
      final cacheDir = await _getCacheDir();
      final fileName = '${_hashPath(videoPath)}.jpg';
      final file = File('$cacheDir/$fileName');

      if (file.existsSync()) return file.path;

      if (videoId != null) {
        final asset = await AssetEntity.fromId(videoId);
        if (asset != null) {
          final data = await asset.thumbnailDataWithSize(
            const ThumbnailSize(400, 225), // 16:9 ratio
          );
          if (data != null) {
            await file.writeAsBytes(data);
            return file.path;
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
      return null;
    }
  }

  static Future<void> clearCache() async {
    final cacheDir = await _getCacheDir();
    final dir = Directory(cacheDir);
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
      dir.createSync();
    }
    _cacheDir = null;
  }
}
