import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Overlay controls for the video player.
/// Tapping shows controls; they auto-hide after 3 seconds.
/// Double-tap left/right seeks ±10 seconds.
class PlayerControls extends StatefulWidget {
  final VideoPlayerController controller;
  final bool isLocked;
  final bool isFullscreen;
  final VoidCallback onToggleLock;
  final VoidCallback onToggleFullscreen;

  const PlayerControls({
    super.key,
    required this.controller,
    required this.isLocked,
    required this.isFullscreen,
    required this.onToggleLock,
    required this.onToggleFullscreen,
  });

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  bool _visible = true;
  static const _hideDelay = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onUpdate);
    _scheduleHide();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  void _show() {
    setState(() => _visible = true);
    _scheduleHide();
  }

  void _scheduleHide() {
    Future.delayed(_hideDelay, () {
      if (mounted && _visible) setState(() => _visible = false);
    });
  }

  void _seekRelative(Duration delta) {
    final current = widget.controller.value.position;
    final total = widget.controller.value.duration;
    final next = current + delta;
    widget.controller.seekTo(
      next < Duration.zero
          ? Duration.zero
          : next > total
              ? total
              : next,
    );
    _show();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _show,
      onDoubleTapDown: widget.isLocked
          ? null
          : (details) {
              final half = MediaQuery.of(context).size.width / 2;
              _seekRelative(details.globalPosition.dx < half
                  ? const Duration(seconds: -10)
                  : const Duration(seconds: 10));
            },
      child: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child:
            widget.isLocked ? _buildLockedOverlay() : _buildFullControls(),
      ),
    );
  }

  Widget _buildLockedOverlay() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: _LockButton(isLocked: true, onTap: widget.onToggleLock),
      ),
    );
  }

  Widget _buildFullControls() {
    final ctrl = widget.controller;
    final value = ctrl.value;
    final isPlaying = value.isPlaying;
    final position = value.position;
    final total = value.duration;
    final progress =
        total.inMilliseconds > 0 ? position.inMilliseconds / total.inMilliseconds : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.45),
            Colors.transparent,
            Colors.black.withOpacity(0.65),
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Centre play/pause
          Center(
            child: GestureDetector(
              onTap: () {
                isPlaying ? ctrl.pause() : ctrl.play();
                _show();
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),

          // Bottom: progress + controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFFFF0000),
                    inactiveTrackColor: Colors.white38,
                    thumbColor: const Color(0xFFFF0000),
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6),
                    overlayShape: SliderComponentShape.noOverlay,
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: progress.clamp(0.0, 1.0),
                    onChanged: (v) {
                      ctrl.seekTo(total * v);
                      _show();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Text(
                        _fmt(position),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        ' / ${_fmt(total)}',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                      ),
                      const Spacer(),
                      _LockButton(
                          isLocked: false, onTap: widget.onToggleLock),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: widget.onToggleFullscreen,
                        child: Icon(
                          widget.isFullscreen
                              ? Icons.fullscreen_exit
                              : Icons.fullscreen,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _LockButton extends StatelessWidget {
  final bool isLocked;
  final VoidCallback onTap;

  const _LockButton({required this.isLocked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        isLocked ? Icons.lock : Icons.lock_open,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}
