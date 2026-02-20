class VideoItem {
  final String id;
  final String path;
  final String title;
  final String folderName;
  final Duration duration;
  final DateTime? dateAdded;
  String? thumbnailPath;

  VideoItem({
    required this.id,
    required this.path,
    required this.title,
    required this.folderName,
    required this.duration,
    this.dateAdded,
    this.thumbnailPath,
  });

  /// Clean a raw filename into a human-readable title.
  /// "my_vacation_clip.mp4" → "My Vacation Clip"
  static String cleanTitle(String filename) {
    final nameWithoutExt = filename.contains('.')
        ? filename.substring(0, filename.lastIndexOf('.'))
        : filename;
    return nameWithoutExt
        .replaceAll(RegExp(r'[_\-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .split(' ')
        .map((word) =>
            word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Format as MM:SS or H:MM:SS
  String get formattedDuration {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'path': path,
        'title': title,
        'folderName': folderName,
        'durationMs': duration.inMilliseconds,
        'dateAdded': dateAdded?.millisecondsSinceEpoch,
        'thumbnailPath': thumbnailPath,
      };

  factory VideoItem.fromJson(Map<String, dynamic> json) => VideoItem(
        id: json['id'] as String,
        path: json['path'] as String,
        title: json['title'] as String,
        folderName: json['folderName'] as String,
        duration: Duration(milliseconds: json['durationMs'] as int),
        dateAdded: json['dateAdded'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['dateAdded'] as int)
            : null,
        thumbnailPath: json['thumbnailPath'] as String?,
      );
}
