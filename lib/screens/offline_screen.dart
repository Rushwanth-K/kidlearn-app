import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../database_helper.dart';
import 'video_player_screen.dart';

class OfflineVideosScreen extends StatefulWidget {
  const OfflineVideosScreen({super.key});

  @override
  State<OfflineVideosScreen> createState() => _OfflineVideosScreenState();
}

class _OfflineVideosScreenState extends State<OfflineVideosScreen> {

  // This list holds all videos loaded from SQLite
  List<Map<String, dynamic>> videos = [];

  // Selected category for filtering
  String selectedCategory = 'All';

  final List<String> categories = [
    'All', 'Education', 'Creativity', 'Nature', 'Stories', 'Other'
  ];

  // Category colors
  final Map<String, Color> categoryColors = {
    'All':        Color(0xFFBA7517),
    'Education':  Color(0xFF185FA5),
    'Creativity': Color(0xFF993556),
    'Nature':     Color(0xFF3B6D11),
    'Stories':    Color(0xFF854F0B),
    'Other':      Color(0xFF555555),
  };

  @override
  void initState() {
    super.initState();
    // Load videos from SQLite when screen opens
    loadVideos();
  }

  // Reads all videos from SQLite database
  Future<void> loadVideos() async {
    final data = await DatabaseHelper.instance.getAllVideos();
    setState(() {
      videos = data;
    });
  }

  // Opens file picker so parent can select a video
  Future<void> pickVideo() async {
    // Show category picker dialog first
    String? selectedCat = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Education', 'Creativity', 'Nature', 'Stories', 'Other']
              .map((cat) => ListTile(
            title: Text(cat),
            onTap: () => Navigator.pop(context, cat),
          ))
              .toList(),
        ),
      ),
    );

    if (selectedCat == null) return;

    // Open file picker to select video
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      final file = result.files.single;

      // Save to SQLite database
      await DatabaseHelper.instance.insertVideo({
        'title': file.name.replaceAll(RegExp(r'\.[^.]+$'), ''),
        'file_path': file.path!,
        'category': selectedCat,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Reload the list
      loadVideos();
    }
  }

  // Delete a video from database
  Future<void> deleteVideo(int id) async {
    await DatabaseHelper.instance.deleteVideo(id);
    loadVideos();
  }

  @override
  Widget build(BuildContext context) {

    // Filter videos by selected category
    final filteredVideos = selectedCategory == 'All'
        ? videos
        : videos.where((v) => v['category'] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: Color(0xFFBA7517),

      // Floating action button — parent taps this to add a video
      floatingActionButton: FloatingActionButton(
        onPressed: pickVideo,
        backgroundColor: Colors.white,
        child: Icon(Icons.add, color: Color(0xFFBA7517)),
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── HEADER ──
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(0xFF8A5510),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),

                  SizedBox(height: 16),

                  Text(
                    'Offline Videos',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  Text(
                    'Parent uploaded videos',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),

                ],
              ),
            ),

            // ── CATEGORY PILLS ──
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: categories.map((category) {
                  bool isSelected = selectedCategory == category;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 8),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Color(0xFFBA7517) : Colors.white,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: 16),

            // ── VIDEO LIST ──
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: filteredVideos.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.video_library_outlined,
                          size: 60, color: Colors.grey.shade300),
                      SizedBox(height: 16),
                      Text(
                        'No videos yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap the + button to add a video',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemCount: filteredVideos.length,
                  itemBuilder: (context, index) {
                    final video = filteredVideos[index];
                    final color = categoryColors[video['category']] ??
                        Color(0xFFBA7517);

                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [

                          // Thumbnail
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoPlayerScreen(
                                    videoPath: video['file_path'],
                                    videoTitle: video['title'],
                                    isOnline: false,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 56,
                              height: 42,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.play_circle,
                                color: color,
                                size: 24,
                              ),
                            ),
                          ),

                          SizedBox(width: 12),

                          // Title and category
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VideoPlayerScreen(
                                      videoPath: video['file_path'],
                                      videoTitle: video['title'],
                                      isOnline: false,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    video['title'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      video['category'],
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Delete button
                          GestureDetector(
                            onTap: () => deleteVideo(video['id']),
                            child: Icon(
                              Icons.delete_outline,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),

                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}