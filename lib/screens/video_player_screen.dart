import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  Future<void> initializePlayer() async {
    // If online, load from URL. If offline, load from local file
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
    setState(() {
      isInitialized = true;
    });
  }

  @override
  void dispose() {
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
      body: SafeArea(
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

                  SizedBox(height: 16),

                  // Play/Pause button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      // Rewind 10 seconds
                      GestureDetector(
                        onTap: () {
                          final pos = _controller.value.position;
                          _controller.seekTo(
                            pos - Duration(seconds: 10),
                          );
                        },
                        child: Icon(Icons.replay_10, color: Colors.white, size: 32),
                      ),

                      SizedBox(width: 32),

                      // Play / Pause
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

                      // Forward 10 seconds
                      GestureDetector(
                        onTap: () {
                          final pos = _controller.value.position;
                          _controller.seekTo(
                            pos + Duration(seconds: 10),
                          );
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
      ),
    );
  }
}