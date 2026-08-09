import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'video_player_screen.dart';
import 'dart:async';
import '../screen_time_service.dart';

class SchoolVideosScreen extends StatefulWidget {
  const SchoolVideosScreen({super.key});

  @override
  State<SchoolVideosScreen> createState() => _SchoolVideosScreenState();
}

class _SchoolVideosScreenState extends State<SchoolVideosScreen> {

  // ── Controllers for input fields ──
  final TextEditingController _schoolIdController = TextEditingController();
  final TextEditingController _standardIdController = TextEditingController();

  List<dynamic> videos = [];
  bool isLoading = false;
  bool hasSearched = false;
  bool isInvalidCode = false;
  Timer? _timer;

  // ── Standard ID labels ──
  final Map<String, String> standardLabels = {
    '01': 'Class 1',
    '02': 'Class 2',
    '03': 'Class 3',
    '04': 'Class 4',
    '05': 'Class 5',
  };

  final Map<String, Color> categoryColors = {
    'Education':  Color(0xFF185FA5),
    'Creativity': Color(0xFF993556),
    'Nature':     Color(0xFF3B6D11),
    'Stories':    Color(0xFF854F0B),
    'Music':      Color(0xFF993C1D),
  };

  final Map<String, Color> categoryBgColors = {
    'Education':  Color(0xFFE6F1FB),
    'Creativity': Color(0xFFF9E8EF),
    'Nature':     Color(0xFFEAF3DE),
    'Stories':    Color(0xFFFAEEDA),
    'Music':      Color(0xFFFAECE7),
  };

  final Map<String, String> categoryIcons = {
    'Education':  '📚',
    'Creativity': '🎨',
    'Nature':     '🌿',
    'Stories':    '📖',
    'Music':      '🎵',
  };

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      await ScreenTimeService.addSeconds(1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _schoolIdController.dispose();
    _standardIdController.dispose();
    super.dispose();
  }

  Future<void> _searchVideos() async {
    final schoolId = _schoolIdController.text.trim();
    final standardId = _standardIdController.text.trim();

    // ── Validation ──
    if (schoolId.isEmpty || schoolId.length != 4) {
      _showError('Please enter a valid 4-digit School ID');
      return;
    }
    if (standardId.isEmpty || standardId.length != 6) {
      _showError('Please enter a valid 6-digit Class ID');
      return;
    }

    setState(() {
      isLoading = true;
      hasSearched = false;
      isInvalidCode = false;
      videos = [];
    });

    final result = await ApiService.getSchoolVideos(schoolId, standardId);

    setState(() {
      isLoading = false;
      hasSearched = true;
      if (result.isEmpty) {
        isInvalidCode = true;
        videos = [];
      } else {
        isInvalidCode = false;
        videos = result;
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFFE24B4A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF185FA5),
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
                            color: Color(0xFF0D4A8A),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.arrow_back, color: Colors.white70, size: 18),
                        ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('School Videos',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text('Teacher uploaded lessons',
                              style: TextStyle(fontSize: 10, color: Color(0xFFB5D4F4))),
                        ],
                      ),
                      Spacer(),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Color(0xFF0D4A8A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(child: Text('🏫', style: TextStyle(fontSize: 20))),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // ── SCHOOL ID INPUT CARD ──
                  Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Color(0xFF0D4A8A),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          'Enter your school code',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Get this from your school or teacher',
                          style: TextStyle(fontSize: 10, color: Color(0xFFB5D4F4)),
                        ),

                        SizedBox(height: 12),

                        // School ID field
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('School ID (4 digits)',
                                      style: TextStyle(fontSize: 10, color: Color(0xFFB5D4F4))),
                                  SizedBox(height: 4),
                                  TextField(
                                    controller: _schoolIdController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 4,
                                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 4),
                                    decoration: InputDecoration(
                                      hintText: '2304',
                                      hintStyle: TextStyle(color: Colors.white30, fontSize: 18, letterSpacing: 4),
                                      filled: true,
                                      fillColor: Color(0xFF185FA5),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      counterText: '',
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(width: 10),

                            // Standard ID field
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Class ID (6 digits)',
                                      style: TextStyle(fontSize: 10, color: Color(0xFFB5D4F4))),
                                  SizedBox(height: 4),
                                  TextField(
                                    controller: _standardIdController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 6,
                                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 4),
                                    decoration: InputDecoration(
                                      hintText: '230401',
                                      hintStyle: TextStyle(color: Colors.white30, fontSize: 18, letterSpacing: 4),
                                      filled: true,
                                      fillColor: Color(0xFF185FA5),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      counterText: '',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 12),

                        // Find Videos button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _searchVideos,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFE24B4A),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: isLoading
                                ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text('Find Videos',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),

                      ],
                    ),
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
                child: !hasSearched
                // ── INITIAL STATE ──
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🏫', style: TextStyle(fontSize: 60)),
                    SizedBox(height: 16),
                    Text('Enter your school code',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF185FA5))),
                    SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Ask your teacher for the School ID and Class ID to see your lessons',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 20),
                    // ID system explanation
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 24),
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Color(0xFFE6F1FB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Color(0xFF185FA5), size: 16),
                              SizedBox(width: 8),
                              Text('How it works',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF185FA5))),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text('School ID: 4 digits (e.g. 2304)\nClass ID: 6 digits (e.g. 230401 for Class 1)',
                              style: TextStyle(fontSize: 11, color: Color(0xFF185FA5))),
                        ],
                      ),
                    ),
                  ],
                )
                    : isInvalidCode
                // ── INVALID CODE STATE ──
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('❌', style: TextStyle(fontSize: 50)),
                    SizedBox(height: 12),
                    Text('Invalid school or class code',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey)),
                    SizedBox(height: 6),
                    Text('Please check your School ID and Class ID\nand try again',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                  ],
                )
                // ── VIDEOS LIST ──
                    : Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Text('${videos.length} lesson${videos.length != 1 ? 's' : ''} found',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF185FA5))),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(0xFFE6F1FB),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Class ${_standardIdController.text.substring(4)}',
                              style: TextStyle(fontSize: 10, color: Color(0xFF185FA5), fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: videos.length,
                        itemBuilder: (context, index) {
                          final video = videos[index];
                          final category = video['category'] ?? 'Education';
                          final color = categoryColors[category] ?? Color(0xFF185FA5);
                          final bg = categoryBgColors[category] ?? Color(0xFFE6F1FB);
                          final icon = categoryIcons[category] ?? '📚';

                          return GestureDetector(
                            onTap: () {
                              _timer?.cancel();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoPlayerScreen(
                                    videoPath: video['url'],
                                    videoTitle: video['title'],
                                    isOnline: true,
                                  ),
                                ),
                              ).then((_) => _startTimer());
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 10),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Color(0xFFEEEDFE), width: 0.5),
                              ),
                              child: Row(
                                children: [

                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: bg,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(child: Text(icon, style: TextStyle(fontSize: 24))),
                                  ),

                                  SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          video['title'] ?? 'Lesson',
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF26215C)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: bg,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(category,
                                                  style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w500)),
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              video['duration'] ?? '',
                                              style: TextStyle(fontSize: 10, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFE6F1FB),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.play_arrow, color: Color(0xFF185FA5), size: 18),
                                  ),

                                ],
                              ),
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