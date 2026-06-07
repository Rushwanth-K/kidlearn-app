
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../database_helper.dart';
import '../screen_time_service.dart';
import 'video_player_screen.dart';
import 'dart:async';

class OfflineVideosScreen extends StatefulWidget {
  const OfflineVideosScreen({super.key});

  @override
  State<OfflineVideosScreen> createState() => _OfflineVideosScreenState();
}

class _OfflineVideosScreenState extends State<OfflineVideosScreen> {

  List<Map<String, dynamic>> videos = [];
  String selectedCategory = 'All';

  // ✅ NEW — screen time timer
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

  final Map<String, Color> categoryBgColors = {
    'All':        Color(0xFFFFEBEB),
    'Education':  Color(0xFFE6F1FB),
    'Creativity': Color(0xFFF9E8EF),
    'Nature':     Color(0xFFEAF3DE),
    'Stories':    Color(0xFFFAEEDA),
    'Music':      Color(0xFFFAECE7),
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
    loadVideos();
    _startTimer(); // ✅ NEW — start tracking screen time
  }

  // ✅ NEW — same pattern as online_screen.dart
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      await ScreenTimeService.addSeconds(1);
      print('Offline screen time: +1 second');
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // ✅ NEW — stop timer when leaving screen
    super.dispose();
  }

  Future<void> loadVideos() async {
    final data = await DatabaseHelper.instance.getAllVideos();
    setState(() => videos = data);
  }

  Future<void> pickVideo() async {
    String? selectedCat = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Select Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3C3489),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Education', 'Creativity', 'Nature', 'Stories', 'Music']
              .map((cat) {
            final color = categoryColors[cat] ?? Color(0xFFE24B4A);
            final bg = categoryBgColors[cat] ?? Color(0xFFFFEBEB);
            final icon = categoryIcons[cat] ?? '🎬';
            return GestureDetector(
              onTap: () => Navigator.pop(context, cat),
              child: Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Text(icon, style: TextStyle(fontSize: 18)),
                    SizedBox(width: 10),
                    Text(
                      cat,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.chevron_right, color: color, size: 18),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );

    if (selectedCat == null) return;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      final file = result.files.single;
      await DatabaseHelper.instance.insertVideo({
        'title': file.name.replaceAll(RegExp(r'\.[^.]+$'), ''),
        'file_path': file.path!,
        'category': selectedCat,
        'created_at': DateTime.now().toIso8601String(),
      });
      loadVideos();
    }
  }

  Future<void> deleteVideo(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Video', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3C3489))),
        content: Text('Are you sure you want to delete this video?', style: TextStyle(fontSize: 13, color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE24B4A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteVideo(id);
      loadVideos();
    }
  }

  List<Map<String, dynamic>> get filteredVideos {
    if (selectedCategory == 'All') return videos;
    return videos.where((v) => v['category'] == selectedCategory).toList();
  }

  int countByCategory(String cat) {
    if (cat == 'All') return videos.length;
    return videos.where((v) => v['category'] == cat).length;
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
              child: Column(
                children: [

                  Row(
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
                          Text('Offline Videos',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          Text('Parent uploaded content',
                              style: TextStyle(
                                  fontSize: 10, color: Color(0xFFAFA9EC))),
                        ],
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: pickVideo,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFFE24B4A),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text('Add Video',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Stats row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color(0xFF26215C),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${videos.length}',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Text('Total',
                                  style: TextStyle(
                                      fontSize: 9, color: Color(0xFFAFA9EC))),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color(0xFF26215C),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${countByCategory('Education')}',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF85B7EB)),
                              ),
                              Text('Education',
                                  style: TextStyle(
                                      fontSize: 9, color: Color(0xFFAFA9EC))),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color(0xFF26215C),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${countByCategory('Nature')}',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF9FE1CB)),
                              ),
                              Text('Nature',
                                  style: TextStyle(
                                      fontSize: 9, color: Color(0xFFAFA9EC))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),

            SizedBox(height: 16),

            // ── WHITE SECTION ──
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF8F7FF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [

                    // Category pills
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Row(
                        children: categories.map((category) {
                          bool isSelected = selectedCategory == category;
                          final color = categoryColors[category] ?? Color(0xFFE24B4A);
                          final icon = categoryIcons[category] ?? '🎬';
                          return GestureDetector(
                            onTap: () =>
                                setState(() => selectedCategory = category),
                            child: Container(
                              margin: EdgeInsets.only(right: 8),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color(0xFFE24B4A)
                                    : Color(0xFFEEEDFE),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$icon $category',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : Color(0xFF3C3489),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    SizedBox(height: 12),

                    // Video list or empty state
                    Expanded(
                      child: filteredVideos.isEmpty
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('📂', style: TextStyle(fontSize: 60)),
                          SizedBox(height: 16),
                          Text(
                            'No videos yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3C3489),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap Add Video to upload\nyour first video for your child',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 24),
                          GestureDetector(
                            onTap: pickVideo,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFE24B4A),
                                    Color(0xFF3C3489),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add,
                                      color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Add First Video',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                          : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredVideos.length,
                        itemBuilder: (context, index) {
                          final video = filteredVideos[index];
                          final color = categoryColors[video['category']] ??
                              Color(0xFFE24B4A);
                          final bg = categoryBgColors[video['category']] ??
                              Color(0xFFFFEBEB);
                          final icon =
                              categoryIcons[video['category']] ?? '🎬';

                          return Container(
                            margin: EdgeInsets.only(bottom: 10),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Color(0xFFEEEDFE), width: 0.5),
                            ),
                            child: Row(
                              children: [

                                // Icon
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: bg,
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(icon,
                                        style:
                                        TextStyle(fontSize: 24)),
                                  ),
                                ),

                                SizedBox(width: 12),

                                // Title and category
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        video['title'],
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF26215C),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 7,
                                                vertical: 2),
                                            decoration: BoxDecoration(
                                              color: bg,
                                              borderRadius:
                                              BorderRadius.circular(
                                                  20),
                                            ),
                                            child: Text(
                                              video['category'],
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  color: color,
                                                  fontWeight:
                                                  FontWeight.w500),
                                            ),
                                          ),
                                          SizedBox(width: 6),
                                          Text('Offline',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(width: 8),

                                // ✅ Play button — timer pauses while video plays
                                GestureDetector(
                                  onTap: () async {
                                    _timer?.cancel(); // ✅ pause timer while video plays
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            VideoPlayerScreen(
                                              videoPath: video['file_path'],
                                              videoTitle: video['title'],
                                              isOnline: false,
                                            ),
                                      ),
                                    );
                                    _startTimer(); // ✅ resume timer when back
                                  },
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFEEEDFE),
                                      borderRadius:
                                      BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.play_arrow,
                                        color: Color(0xFFE24B4A),
                                        size: 18),
                                  ),
                                ),

                                SizedBox(width: 6),

                                // Delete button
                                GestureDetector(
                                  onTap: () =>
                                      deleteVideo(video['id']),
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFEBEB),
                                      borderRadius:
                                      BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.delete_outline,
                                        color: Color(0xFFE24B4A),
                                        size: 18),
                                  ),
                                ),

                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}