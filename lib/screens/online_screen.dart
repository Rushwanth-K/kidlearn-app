import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'video_player_screen.dart';
import 'shorts_player_screen.dart';
import 'dart:async';
import '../screen_time_service.dart';

class OnlineVideosScreen extends StatefulWidget {
  const OnlineVideosScreen({super.key});

  @override
  State<OnlineVideosScreen> createState() => _OnlineVideosScreenState();
}

class _OnlineVideosScreenState extends State<OnlineVideosScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  String selectedCategory = 'All';
  List<dynamic> allVideos = [];
  List<dynamic> shortVideos = [];
  bool isLoading = true;
  Timer? _timer;

  final List<String> categories = [
    'All', 'Education', 'Creativity', 'Nature', 'Stories', 'Music'
  ];

  final Map<String, Color> categoryColors = {
    'All':        Color(0xFFE24B4A),
    'Education':  Color(0xFF185FA5),
    'Creativity': Color(0xFF993556),
    'Nature':     Color(0xFF3B6D11),
    'Stories':    Color(0xFF854F0B),
    'Music':      Color(0xFF993C1D),
  };

  final Map<String, String> categoryIcons = {
    'All':        '🎬',
    'Education':  '📚',
    'Creativity': '🎨',
    'Nature':     '🌿',
    'Stories':    '📖',
    'Music':      '🎵',
  };
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadVideos();
    _startTimer();

    _tabController.addListener(() {
      if (_tabController.index == 1 && !_tabController.indexIsChanging) {
        if (shortVideos.isNotEmpty) {
          Future.microtask(() {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ShortsPlayerScreen(
                      videos: shortVideos,
                      initialIndex: 0,
                    ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: Duration(milliseconds: 300),
              ),
            ).then((_) {
              if (mounted) _tabController.animateTo(0);
            });
          });
        }
      }
    });
  }
  Future<void> loadVideos() async {
    setState(() => isLoading = true);
    final data = await ApiService.getVideos();
    setState(() {
      // Videos tab — only long videos (is_short = 0)
      allVideos = data.where((v) => v['is_short'] == 0).toList();
      // Shorts tab — only short videos (is_short = 1)
      shortVideos = data.where((v) => v['is_short'] == 1).toList();
      isLoading = false;
    });
  }
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      await ScreenTimeService.addSeconds(1);
      print('Added 1 second to screen time');
    });
  }

@override
void dispose() {
_timer?.cancel();
_tabController.dispose();
super.dispose();
}


  List<dynamic> get filteredVideos {
    if (selectedCategory == 'All') return allVideos;
    return allVideos.where((v) => v['category'] == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF3C3489),
      body: SafeArea(
        child: Column(
          children: [

            // ── HEADER ──
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Color(0xFF26215C),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.arrow_back,
                          color: Colors.white70, size: 18),
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Online Videos',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text('Safe & curated for you',
                          style: TextStyle(
                              fontSize: 10, color: Color(0xFFAFA9EC))),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 14),

            // ── TAB BAR ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF26215C),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Color(0xFFE24B4A),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Color(0xFFAFA9EC),
                  labelStyle:
                  TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  unselectedLabelStyle: TextStyle(fontSize: 12),
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: '📺  Videos'),
                    Tab(text: '⚡  Shorts'),
                  ],
                ),
              ),
            ),

            SizedBox(height: 14),

            // ── TAB CONTENT ──
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [

                  // ── VIDEOS TAB ──
                  Column(
                    children: [

                      // Category pills
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: categories.map((category) {
                            bool isSelected = selectedCategory == category;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => selectedCategory = category),
                              child: Container(
                                margin: EdgeInsets.only(right: 8),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Color(0xFFE24B4A)
                                      : Color(0xFF26215C),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${categoryIcons[category]} $category',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.white
                                        : Color(0xFFAFA9EC),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      SizedBox(height: 12),

                      // Video list
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFF8F7FF),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                          child: isLoading
                              ? Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFFE24B4A)))
                              : filteredVideos.isEmpty
                              ? Center(
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Text('🎬',
                                    style:
                                    TextStyle(fontSize: 50)),
                                SizedBox(height: 12),
                                Text('No videos yet',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14)),
                                SizedBox(height: 6),
                                Text(
                                  'Long videos coming soon!',
                                  style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          )
                              : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: filteredVideos.length,
                            itemBuilder: (context, index) {
                              final video = filteredVideos[index];
                              final color =
                                  categoryColors[video['category']] ??
                                      Color(0xFFE24B4A);
                              final icon =
                                  categoryIcons[video['category']] ??
                                      '🎬';

                              return GestureDetector(
                                onTap: () async {
                                  // Log this video play to watch history
                                  final childId = await ApiService.getChildId();
                                  await ApiService.logWatchHistory(
                                    childId: childId,
                                    videoId: video['id'],
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VideoPlayerScreen(
                                        videoPath: video['url'],
                                        videoTitle: video['title'],
                                        isOnline: true,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin:
                                  EdgeInsets.only(bottom: 10),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.circular(14),
                                    border: Border.all(
                                        color: Color(0xFFEEEDFE),
                                        width: 0.5),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: color
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                          BorderRadius.circular(
                                              12),
                                        ),
                                        child: Center(
                                            child: Text(icon,
                                                style: TextStyle(
                                                    fontSize: 24))),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: [
                                            Text(
                                              video['title'],
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                  color: Color(
                                                      0xFF26215C)),
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets
                                                      .symmetric(
                                                      horizontal:
                                                      7,
                                                      vertical:
                                                      2),
                                                  decoration:
                                                  BoxDecoration(
                                                    color: color
                                                        .withOpacity(
                                                        0.12),
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                        20),
                                                  ),
                                                  child: Text(
                                                      video[
                                                      'category'],
                                                      style: TextStyle(
                                                          fontSize: 9,
                                                          color:
                                                          color,
                                                          fontWeight:
                                                          FontWeight
                                                              .w500)),
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                    '${video['duration']} · Age ${video['age_min']}-${video['age_max']}',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors
                                                            .grey)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFEEEDFE),
                                          borderRadius:
                                          BorderRadius.circular(
                                              8),
                                        ),
                                        child: Icon(Icons.play_arrow,
                                            color: Color(0xFFE24B4A),
                                            size: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    ],
                  ),

                  // ── SHORTS TAB ──
                  // This tab immediately navigates to fullscreen player
                  // via the TabController listener in initState
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Center(
                      child: isLoading
                          ? CircularProgressIndicator(
                          color: Color(0xFFE24B4A))
                          : shortVideos.isEmpty
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('⚡',
                              style: TextStyle(fontSize: 50)),
                          SizedBox(height: 12),
                          Text('No shorts yet',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14)),
                        ],
                      )
                          : CircularProgressIndicator(
                          color: Color(0xFFE24B4A)),
                    ),
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