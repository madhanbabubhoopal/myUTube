import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../models/video_item.dart';
import '../providers/video_provider.dart';
import '../widgets/player_controls.dart';
import '../widgets/swipe_video_tray.dart';
import '../widgets/video_card.dart';

class PlayerScreen extends StatefulWidget {
  final VideoItem video;
  final List<VideoItem> queue;

  const PlayerScreen({
    super.key,
    required this.video,
    required this.queue,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController _controller;
  late VideoItem _currentVideo;
  List<VideoItem> _upNext = [];

  bool _isFullscreen = false;
  bool _isLocked = false;
  bool _showTray = false;
  bool _initialised = false;
  String? _error;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _currentVideo = widget.video;
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final provider = context.read<VideoProvider>();
    _upNext = provider.getUpNext(_currentVideo);

    final controller = _currentVideo.isAsset
        ? VideoPlayerController.asset(_currentVideo.path)
        : VideoPlayerController.file(File(_currentVideo.path));

    try {
      await controller.initialize();

      // ── Resume Progress ────────────────────────────────────────────────
      final savedProgress = await provider.getVideoProgress(_currentVideo.id);
      if (savedProgress > Duration.zero) {
        // If near end, don't seek
        if (savedProgress < controller.value.duration - const Duration(seconds: 5)) {
          await controller.seekTo(savedProgress);
        }
      }

      controller.addListener(_onPlaybackEvent);
      if (mounted) {
        setState(() {
          _controller = controller;
          _initialised = true;
          _error = null;
        });
        if (provider.autoplay) _controller.play();

        // Start periodic progress saving
        _progressTimer?.cancel();
        _progressTimer = Timer.periodic(const Duration(seconds: 5), (_) => _saveProgress());
      } else {
        controller.dispose();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 
          'Cannot play this video.\n'
          'Tip: If this is a local file, ensure it exists at: ${_currentVideo.path}\n'
          'Error details: ${e.toString()}');
      }
      controller.dispose();
    }
  }

  void _onPlaybackEvent() {
    if (!_initialised || !mounted) return;
    final v = _controller.value;
    if (!v.isPlaying && v.position >= v.duration && v.duration > Duration.zero) {
      // Clear progress when finished
      context.read<VideoProvider>().saveVideoProgress(_currentVideo.id, Duration.zero);

      final provider = context.read<VideoProvider>();
      if (provider.autoplay && _upNext.isNotEmpty) {
        _switchVideo(_upNext.first);
      }
    }
  }

  Future<void> _saveProgress() async {
    if (!_initialised || !mounted || !_controller.value.isPlaying) return;
    context.read<VideoProvider>().saveVideoProgress(
      _currentVideo.id,
      _controller.value.position,
    );
  }

  Future<void> _switchVideo(VideoItem video) async {
    _progressTimer?.cancel();
    _saveProgress(); // Final save before switch
    _controller.removeListener(_onPlaybackEvent);
    await _controller.dispose();
    setState(() {
      _currentVideo = video;
      _initialised = false;
      _error = null;
    });
    _initPlayer();
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      // Use immersiveSticky for notched displays like Redmi 13C
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [],
      );
    } else {
      _exitFullscreen();
    }
  }

  void _exitFullscreen() {
    setState(() {
      _isFullscreen = false;
      _isLocked = false;
      _showTray = false;
    });
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _toggleLock() {
    setState(() => _isLocked = !_isLocked);
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _saveProgress();
    if (_initialised) {
      _controller.removeListener(_onPlaybackEvent);
      _controller.dispose();
    }
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _exitFullscreen(); // Reset orientation and overlays
        }
      },
      child: _isFullscreen ? _buildFullscreen() : _buildInline(),
    );
  }

  // ── Inline Mode ────────────────────────────────────────────────────────

  Widget _buildInline() {
    final isDark = context.watch<VideoProvider>().isDarkMode;
    final bgColor = isDark ? const Color(0xFF0F0F0F) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F0F0F);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF0000),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _currentVideo.title,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Player at ~40% (16:9)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildPlayerArea(fullscreen: false),
          ),
          // Title + folder
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Text(
              _currentVideo.title,
              style: TextStyle(
                color: textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 12),
            child: Text(
              _currentVideo.folderName,
              style: const TextStyle(
                  color: Color(0xFF606060), fontSize: 13),
            ),
          ),
          // Inline controls (simple)
          if (_initialised)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _InlineProgressBar(controller: _controller),
            ),
          const Divider(height: 20),
          // Up Next label
          const Padding(
            padding: EdgeInsets.only(left: 12, bottom: 4),
            child: Text(
              'Up Next',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          // Up Next list
          Expanded(
            child: _upNext.isEmpty
                ? const Center(
                    child: Text('No more videos in this folder.',
                        style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _upNext.length,
                    itemBuilder: (context, i) => VideoCard(
                      video: _upNext[i],
                      onTap: () => _switchVideo(_upNext[i]),
                    ),
                  ),
          ),
        ],
      )),
    );
  }

  // ── Fullscreen Mode ────────────────────────────────────────────────────

  Widget _buildFullscreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video fills screen
          Center(child: _buildPlayerArea(fullscreen: true)),

          // Controls overlay
          if (_initialised)
            Positioned.fill(
              child: PlayerControls(
                controller: _controller,
                isLocked: _isLocked,
                isFullscreen: true,
                onToggleLock: _toggleLock,
                onToggleFullscreen: _toggleFullscreen,
              ),
            ),

          // Swipe-up zone to open thumbnail tray (60px at bottom)
          if (!_isLocked && !_showTray)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 60,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragEnd: (d) {
                  if ((d.primaryVelocity ?? 0) < -200) {
                    setState(() => _showTray = true);
                  }
                },
                child: Container(color: Colors.transparent),
              ),
            ),

          // Horizontal swipe zone for ±10s seek
          if (!_isLocked)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragEnd: (d) {
                  if (!_initialised) return;
                  final vel = d.primaryVelocity ?? 0;
                  if (vel.abs() < 300) return;
                  _seekRelative(vel > 0
                      ? const Duration(seconds: 10)
                      : const Duration(seconds: -10));
                },
                child: Container(color: Colors.transparent),
              ),
            ),

          // Thumbnail tray
          if (_showTray && _upNext.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SwipeVideoTray(
                videos: _upNext.take(5).toList(),
                onVideoSelected: (v) {
                  setState(() => _showTray = false);
                  _switchVideo(v);
                },
                onDismiss: () => setState(() => _showTray = false),
              ),
            ),
        ],
      ),
    );
  }

  // ── Shared ─────────────────────────────────────────────────────────────

  Widget _buildPlayerArea({required bool fullscreen}) {
    if (_error != null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_initialised) {
      return Container(
        color: Colors.black,
        child: const Center(
          child:
              CircularProgressIndicator(color: Color(0xFFFF0000)),
        ),
      );
    }

    final player = AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    );

    if (fullscreen) return player;

    // In inline mode, wrap with a tap-to-toggle-fullscreen gesture
    return GestureDetector(
      onTap: _toggleFullscreen,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(child: player),
          const Positioned(
            bottom: 8,
            right: 8,
            child: Icon(Icons.fullscreen, color: Colors.white70, size: 28),
          ),
        ],
      ),
    );
  }

  void _seekRelative(Duration delta) {
    if (!_initialised) return;
    final pos = _controller.value.position + delta;
    final total = _controller.value.duration;
    _controller.seekTo(
      pos < Duration.zero
          ? Duration.zero
          : pos > total
              ? total
              : pos,
    );
  }
}

/// Simple inline progress + play/pause bar shown below the player.
class _InlineProgressBar extends StatefulWidget {
  final VideoPlayerController controller;
  const _InlineProgressBar({required this.controller});

  @override
  State<_InlineProgressBar> createState() => _InlineProgressBarState();
}

class _InlineProgressBarState extends State<_InlineProgressBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_update);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    super.dispose();
  }

  void _update() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.controller.value;
    final progress = v.duration.inMilliseconds > 0
        ? v.position.inMilliseconds / v.duration.inMilliseconds
        : 0.0;

    return Row(
      children: [
        IconButton(
          icon: Icon(v.isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () =>
              v.isPlaying ? widget.controller.pause() : widget.controller.play(),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFFF0000),
              inactiveTrackColor: Colors.grey[300],
              thumbColor: const Color(0xFFFF0000),
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: SliderComponentShape.noOverlay,
              trackHeight: 3,
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: (val) =>
                  widget.controller.seekTo(v.duration * val),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            _fmt(v.position),
            style: const TextStyle(fontSize: 12, color: Color(0xFF606060)),
          ),
        ),
      ],
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
