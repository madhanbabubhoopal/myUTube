import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// Parameters struct passed to the background isolate.
/// Must be a plain data object (no closures, no platform channels).
class _ThumbnailParams {
  final String videoPath;
  final String outputDir;
  final String cacheKey;

  const _ThumbnailParams({
    required this.videoPath,
    required this.outputDir,
    required this.cacheKey,
  });
}

/// Top-level function — required by compute() (must not be a closure).
Future<String?> _generateInIsolate(_ThumbnailParams params) async {
  final outputPath = '${params.outputDir}/${params.cacheKey}.jpg';
  if (File(outputPath).existsSync()) return outputPath;

  try {
    return await VideoThumbnail.thumbnailFile(
      video: params.videoPath,
      thumbnailPath: params.outputDir,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 180,
      maxWidth: 320,
      quality: 70,
      timeMs: 0,
    );
  } catch (_) {
    return null;
  }
}

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

  /// Simple non-cryptographic hash of the file path used as cache filename.
  static String _hashPath(String path) {
    var hash = 0;
    for (int i = 0; i < path.length; i++) {
      hash = (hash * 31 + path.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return hash.toString();
  }

  /// Generate a thumbnail for a local video file.
  /// Runs in a background Dart isolate via compute() — no UI jank.
  /// Returns the cache file path, or null on failure.
  static Future<String?> generateThumbnail(String videoPath) async {
    final cacheDir = await _getCacheDir();
    final cacheKey = _hashPath(videoPath);
    final cachedFile = File('$cacheDir/$cacheKey.jpg');

    if (cachedFile.existsSync()) return cachedFile.path;

    return compute(
      _generateInIsolate,
      _ThumbnailParams(
        videoPath: videoPath,
        outputDir: cacheDir,
        cacheKey: cacheKey,
      ),
    );
  }

  /// Delete all cached thumbnails.
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
