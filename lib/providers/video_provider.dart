import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video_item.dart';
import '../utils/video_scanner.dart';
import '../utils/thumbnail_helper.dart';

class VideoProvider extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────
  List<VideoItem> _allVideos = [];
  List<VideoItem> _searchResults = [];
  Map<String, List<VideoItem>> _videosByFolder = {};

  bool _isLoading = false;
  bool _isScanning = false;
  int _scanProgress = 0;
  int _scanTotal = 0;

  bool _permissionDenied = false;

  // Settings
  bool _autoplay = true;
  bool _shuffle = false;
  bool _isDarkMode = false;
  String _parentalPin = '1234';
  List<String> _hiddenFolders = [];
  String _searchQuery = '';

  // ── Getters ────────────────────────────────────────────────────────────────
  List<VideoItem> get allVideos => _allVideos;

  List<VideoItem> get visibleVideos {
    // Only show approved videos to the child
    final visible = _allVideos
        .where((v) => v.isApproved && !_hiddenFolders.contains(v.folderName))
        .toList();
    if (_shuffle) visible.shuffle();
    return visible;
  }

  List<VideoItem> get searchResults => _searchResults;
  Map<String, List<VideoItem>> get videosByFolder => _videosByFolder;

  bool get isLoading => _isLoading;
  bool get isScanning => _isScanning;
  int get scanProgress => _scanProgress;
  int get scanTotal => _scanTotal;
  bool get permissionDenied => _permissionDenied;

  bool get autoplay => _autoplay;
  bool get shuffle => _shuffle;
  bool get isDarkMode => _isDarkMode;
  String get parentalPin => _parentalPin;
  List<String> get hiddenFolders => List.unmodifiable(_hiddenFolders);
  String get searchQuery => _searchQuery;

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Toggles the approval status of a video (Parental Control).
  Future<void> toggleApproval(String videoId) async {
    final index = _allVideos.indexWhere((v) => v.id == videoId);
    if (index != -1) {
      _allVideos[index].isApproved = !_allVideos[index].isApproved;
      await _cacheVideos();
      _buildFolderMap();
      notifyListeners();
    }
  }

  // ── Initialisation ─────────────────────────────────────────────────────────

  /// Call on app start. Loads cache first for instant display, then rescans.
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await _loadSettings();
    await _loadCachedVideos();

    _isLoading = false;
    notifyListeners();

    await _performScan();
  }

  // ── Settings persistence ───────────────────────────────────────────────────

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _autoplay = prefs.getBool('autoplay') ?? true;
    _shuffle = prefs.getBool('shuffle') ?? false;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _parentalPin = prefs.getString('parentalPin') ?? '1234';
    _hiddenFolders = prefs.getStringList('hiddenFolders') ?? [];
  }

  Future<void> _loadCachedVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cachedVideos');
    if (cached == null) return;
    try {
      final list = jsonDecode(cached) as List<dynamic>;
      _allVideos =
          list.map((j) => VideoItem.fromJson(j as Map<String, dynamic>)).toList();
      _buildFolderMap();
    } catch (_) {
      // Corrupted cache — ignore; live scan will replace it
    }
  }

  Future<void> _cacheVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_allVideos.map((v) => v.toJson()).toList());
    await prefs.setString('cachedVideos', encoded);
  }

  // ── Scanning ───────────────────────────────────────────────────────────────

  Future<void> _performScan() async {
    _isScanning = true;
    _scanProgress = 0;
    _scanTotal = 0;
    notifyListeners();

    final granted = await VideoScanner.requestPermission();
    if (!granted) {
      _permissionDenied = true;
      _isScanning = false;
      notifyListeners();
      return;
    }

    _permissionDenied = false;

    final videos = await VideoScanner.scanAllVideos(
      onProgress: (loaded, total) {
        _scanProgress = loaded;
        _scanTotal = total;
        notifyListeners();
      },
    );

    _allVideos = videos;

    // ── Demo Mode / Initial State ─────────────────────────────────────
    // If no videos are found, add sample entries for testing/onboarding.
    if (_allVideos.isEmpty) {
      _allVideos.addAll([
        VideoItem(
          id: 'demo_1',
          path: '/Users/vik/projects/kidsTube/data/playtime-with-daniel/intro.mp4',
          title: 'Welcome to KidsTube',
          folderName: 'Playtime with Daniel',
          duration: const Duration(minutes: 2, seconds: 30),
          isApproved: true,
        ),
        VideoItem(
          id: 'demo_2',
          path: '/Users/vik/projects/kidsTube/data/playtime-with-daniel/episode1.mp4',
          title: 'Daniel Episode 1',
          folderName: 'Playtime with Daniel',
          duration: const Duration(minutes: 11, seconds: 45),
          isApproved: false,
        ),
      ]);
    }

    _buildFolderMap();
    _isScanning = false;
    notifyListeners();

    await _cacheVideos();

    // Generate thumbnails progressively without blocking the UI
    _generateThumbnailsInBackground();
  }

  void _buildFolderMap() {
    _videosByFolder = {};
    for (final video in _allVideos) {
      _videosByFolder.putIfAbsent(video.folderName, () => []).add(video);
    }
  }

  void _generateThumbnailsInBackground() async {
    for (final video in List<VideoItem>.from(_allVideos)) {
      if (video.thumbnailPath != null) continue;
      final thumbPath = await ThumbnailHelper.generateThumbnail(video.path);
      if (thumbPath != null) {
        video.thumbnailPath = thumbPath;
        notifyListeners();
      }
    }
  }

  /// Refresh: clears thumbnail cache, rescans the device.
  Future<void> refreshLibrary() async {
    await ThumbnailHelper.clearCache();
    for (final v in _allVideos) {
      v.thumbnailPath = null;
    }
    await _performScan();
  }

  /// Open system app settings (for permanently denied permission on MIUI).
  Future<void> openSettings() async {
    await openAppSettings();
  }

  // ── Search ─────────────────────────────────────────────────────────────────

  void search(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _searchResults = [];
    } else {
      final q = query.toLowerCase();
      _searchResults = _allVideos
          .where((v) =>
              v.title.toLowerCase().contains(q) ||
              v.folderName.toLowerCase().contains(q))
          .toList();
    }
    notifyListeners();
  }

  // ── Settings mutations ─────────────────────────────────────────────────────

  Future<void> setAutoplay(bool value) async {
    _autoplay = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoplay', value);
    notifyListeners();
  }

  Future<void> setShuffle(bool value) async {
    _shuffle = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('shuffle', value);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> updatePin(String newPin) async {
    _parentalPin = newPin;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('parentalPin', newPin);
    notifyListeners();
  }

  bool validatePin(String pin) => pin == _parentalPin;

  Future<void> toggleFolderVisibility(String folderName) async {
    if (_hiddenFolders.contains(folderName)) {
      _hiddenFolders.remove(folderName);
    } else {
      _hiddenFolders.add(folderName);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('hiddenFolders', _hiddenFolders);
    notifyListeners();
  }

  // ── Playback helpers ───────────────────────────────────────────────────────

  /// Returns up-to [count] videos that follow [current] in its folder.
  List<VideoItem> getUpNext(VideoItem current, {int count = 10}) {
    final folder = _videosByFolder[current.folderName] ?? [];
    final idx = folder.indexWhere((v) => v.id == current.id);
    if (idx < 0 || idx >= folder.length - 1) return [];
    final next = folder.sublist(idx + 1);
    if (_shuffle) next.shuffle();
    return next.take(count).toList();
  }
}
