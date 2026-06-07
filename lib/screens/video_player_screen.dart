import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

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

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  Future<void> initializePlayer() async {
    if (widget.isOnline) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoPath),
      );
    } else {
      _controller = VideoPlayerController.contentUri(
        Uri.parse(widget.videoPath),
      );
    }

    await _controller.initialize();

    // ✅ Check if video is landscape or portrait
    final size = _controller.value.size;
    final videoIsLandscape = size.width > size.height;

    if (videoIsLandscape) {
      // ✅ Force landscape orientation for landscape videos
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    setState(() {
      isInitialized = true;
      isLandscape = videoIsLandscape;
      isPlaying = true;
    });

    _controller.play();
  }

  @override
  void dispose() {
    // ✅ Restore portrait orientation when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _controller.dispose();
    super.dispose();
  }

  void togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        isPlaying = false;
      } else {
        _controller.play();
        isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLandscape ? _buildLandscapeLayout() : _buildPortraitLayout(),
    );
  }

  // ✅ LANDSCAPE LAYOUT — video fills full screen
  Widget _buildLandscapeLayout() {
    return Stack(
      children: [

        // Video fills entire screen
        Center(
          child: isInitialized
              ? SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          )
              : CircularProgressIndicator(color: Colors.white),
        ),

        // ── TOP BAR overlay ──
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── BOTTOM CONTROLS overlay ──
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
            child: Column(
              children: [
                // Progress bar
                isInitialized
                    ? VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: Colors.white,
                    bufferedColor: Colors.white38,
                    backgroundColor: Colors.white12,
                  ),
                )
                    : SizedBox(),

                SizedBox(height: 10),

                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        final pos = _controller.value.position;
                        _controller.seekTo(pos - Duration(seconds: 10));
                      },
                      child: Icon(Icons.replay_10, color: Colors.white, size: 30),
                    ),
                    SizedBox(width: 28),
                    GestureDetector(
                      onTap: togglePlay,
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.black,
                          size: 28,
                        ),
                      ),
                    ),
                    SizedBox(width: 28),
                    GestureDetector(
                      onTap: () {
                        final pos = _controller.value.position;
                        _controller.seekTo(pos + Duration(seconds: 10));
                      },
                      child: Icon(Icons.forward_10, color: Colors.white, size: 30),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }

  // ✅ PORTRAIT LAYOUT — original layout for vertical videos
  Widget _buildPortraitLayout() {
    return SafeArea(
      child: Column(
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // ── VIDEO PLAYER ──
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
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [

                isInitialized
                    ? VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: Colors.white,
                    bufferedColor: Colors.white38,
                    backgroundColor: Colors.white12,
                  ),
                )
                    : SizedBox(),

                SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        final pos = _controller.value.position;
                        _controller.seekTo(pos - Duration(seconds: 10));
                      },
                      child: Icon(Icons.replay_10, color: Colors.white, size: 32),
                    ),
                    SizedBox(width: 32),
                    GestureDetector(
                      onTap: togglePlay,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.black,
                          size: 32,
                        ),
                      ),
                    ),
                    SizedBox(width: 32),
                    GestureDetector(
                      onTap: () {
                        final pos = _controller.value.position;
                        _controller.seekTo(pos + Duration(seconds: 10));
                      },
                      child: Icon(Icons.forward_10, color: Colors.white, size: 32),
                    ),
                  ],
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }
}