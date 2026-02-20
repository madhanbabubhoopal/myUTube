import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../models/video_item.dart';
import '../providers/video_provider.dart';

/// YouTube Shorts-style full-screen vertical swipe feed.
class ClipsScreen extends StatefulWidget {
  const ClipsScreen({super.key});

  @override
  State<ClipsScreen> createState() => _ClipsScreenState();
}

class _ClipsScreenState extends State<ClipsScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videos = context.watch<VideoProvider>().visibleVideos;

    if (videos.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'No clips available.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: videos.length,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemBuilder: (context, index) => _ClipPage(
          video: videos[index],
          isActive: index == _currentIndex,
        ),
      ),
    );
  }
}

class _ClipPage extends StatefulWidget {
  final VideoItem video;
  final bool isActive;

  const _ClipPage({required this.video, required this.isActive});

  @override
  State<_ClipPage> createState() => _ClipPageState();
}

class _ClipPageState extends State<_ClipPage> {
  VideoPlayerController? _controller;
  bool _initialised = false;
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _controller = VideoPlayerController.file(File(widget.video.path));
    try {
      await _controller!.initialize();
      _controller!.setLooping(true);
      if (widget.isActive) _controller!.play();
      if (mounted) setState(() => _initialised = true);
    } catch (_) {
      if (mounted) setState(() => _initialised = false);
    }
  }

  @override
  void didUpdateWidget(_ClipPage old) {
    super.didUpdateWidget(old);
    if (_initialised) {
      widget.isActive ? _controller!.play() : _controller!.pause();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_initialised) {
          setState(() => _showControls = !_showControls);
          if (_controller!.value.isPlaying) {
            _controller!.pause();
          } else {
            _controller!.play();
          }
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black),
          if (_initialised)
            Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            )
          else
            const Center(
              child:
                  CircularProgressIndicator(color: Color(0xFFFF0000)),
            ),
          // Bottom-left title overlay
          Positioned(
            left: 16,
            bottom: 80,
            right: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.video.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                  ),
                ),
                Text(
                  widget.video.folderName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                  ),
                ),
              ],
            ),
          ),
          // Subtle play/pause icon when tapped
          if (_showControls && _initialised)
            Center(
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _controller!.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Colors.white70,
                  size: 64,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
