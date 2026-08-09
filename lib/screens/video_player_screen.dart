import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  final String videoTitle;
  final bool isOnline;

  const VideoPlayerScreen({
    super.key,
    required this.videoPath,
    required this.videoTitle,
    required this.isOnline,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {

  late VideoPlayerController _controller;
  bool isPlaying = false;
  bool isInitialized = false;
  bool isLandscape = false;

  // ✅ Controls visibility
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  Future<void> initializePlayer() async {
    if (widget.isOnline) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoPath));
    } else {
      _controller = VideoPlayerController.contentUri(Uri.parse(widget.videoPath));
    }

    await _controller.initialize();

    final size = _controller.value.size;
    final videoIsLandscape = size.width > size.height;
    if (videoIsLandscape) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); // ✅ ADD
    }

    setState(() {
      isInitialized = true;
      isLandscape = videoIsLandscape;
      isPlaying = true;
    });

    _controller.play();
    _startHideTimer(); // ✅ auto-hide controls after 3 seconds
  }
  @override
  void dispose() {
    _hideTimer?.cancel();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); // ✅ ADD
    _controller.dispose();
    super.dispose();
  }

  void togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        isPlaying = false;
        // ✅ Keep controls visible when paused
        _hideTimer?.cancel();
      } else {
        _controller.play();
        isPlaying = true;
        _startHideTimer();
      }
    });
  }

  // ✅ Show controls on tap, auto-hide after 3 seconds
  void _onTapScreen() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _startHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(Duration(seconds: 3), () {
      if (mounted && _controller.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _onTapScreen,
        child: isLandscape ? _buildLandscapeLayout() : _buildPortraitLayout(),
      ),
    );
  }

  // ✅ LANDSCAPE LAYOUT
  Widget _buildLandscapeLayout() {
    return Stack(
      children: [

        // Video fills entire screen
        Center(
          child: isInitialized
              ? SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.fill,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          )
              : CircularProgressIndicator(color: Colors.white),
        ),

        // ✅ Controls overlay — shown/hidden on tap
        AnimatedOpacity(
          opacity: _showControls ? 1.0 : 0.0,
          duration: Duration(milliseconds: 300),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black54,
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black54,
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: Column(
              children: [

                // ── TOP BAR ──
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.arrow_back, color: Colors.white, size: 18),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.videoTitle,
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                Spacer(),

                // ── BOTTOM CONTROLS ──
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Column(
                    children: [

                      // Progress bar
                      if (isInitialized)
                        VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors: VideoProgressColors(
                            playedColor: Colors.white,
                            bufferedColor: Colors.white38,
                            backgroundColor: Colors.white24,
                          ),
                        ),

                      SizedBox(height: 10),

                      // Play/Pause + seek buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              final pos = _controller.value.position;
                              _controller.seekTo(pos - Duration(seconds: 10));
                              _startHideTimer();
                            },
                            child: Icon(Icons.replay_10, color: Colors.white, size: 30),
                          ),
                          SizedBox(width: 28),
                          GestureDetector(
                            onTap: togglePlay,
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.black, size: 28),
                            ),
                          ),
                          SizedBox(width: 28),
                          GestureDetector(
                            onTap: () {
                              final pos = _controller.value.position;
                              _controller.seekTo(pos + Duration(seconds: 10));
                              _startHideTimer();
                            },
                            child: Icon(Icons.forward_10, color: Colors.white, size: 30),
                          ),
                        ],
                      ),

                      SizedBox(height: 8),

                      // Time display
                      if (isInitialized)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_controller.value.position),
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                            Text(
                              _formatDuration(_controller.value.duration),
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),

                    ],
                  ),
                ),

              ],
            ),
          ),
        ),

      ],
    );
  }

  // ✅ PORTRAIT LAYOUT
  Widget _buildPortraitLayout() {
    return SafeArea(
      child: Stack(
        children: [

          Column(
            children: [

              // ── TOP BAR ──
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.arrow_back, color: Colors.white, size: 18),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.videoTitle,
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // ── VIDEO ──
              Expanded(
                child: Center(
                  child: isInitialized
                      ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                      : CircularProgressIndicator(color: Colors.white),
                ),
              ),

              // ── CONTROLS ──
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: Duration(milliseconds: 300),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [

                      if (isInitialized)
                        VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors: VideoProgressColors(
                            playedColor: Colors.white,
                            bufferedColor: Colors.white38,
                            backgroundColor: Colors.white12,
                          ),
                        ),

                      SizedBox(height: 8),

                      if (isInitialized)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(_controller.value.position), style: TextStyle(color: Colors.white70, fontSize: 11)),
                            Text(_formatDuration(_controller.value.duration), style: TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),

                      SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              final pos = _controller.value.position;
                              _controller.seekTo(pos - Duration(seconds: 10));
                              _startHideTimer();
                            },
                            child: Icon(Icons.replay_10, color: Colors.white, size: 32),
                          ),
                          SizedBox(width: 32),
                          GestureDetector(
                            onTap: togglePlay,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.black, size: 32),
                            ),
                          ),
                          SizedBox(width: 32),
                          GestureDetector(
                            onTap: () {
                              final pos = _controller.value.position;
                              _controller.seekTo(pos + Duration(seconds: 10));
                              _startHideTimer();
                            },
                            child: Icon(Icons.forward_10, color: Colors.white, size: 32),
                          ),
                        ],
                      ),

                      SizedBox(height: 8),

                    ],
                  ),
                ),
              ),

            ],
          ),

        ],
      ),
    );
  }

  // ✅ Format duration as mm:ss
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}