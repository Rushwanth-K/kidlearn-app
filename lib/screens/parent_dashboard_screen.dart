import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import '../screen_time_service.dart';

class ParentDashboardScreen extends StatefulWidget {
  final int parentId;
  const ParentDashboardScreen({super.key, required this.parentId});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {

  Future<void> handleLogout() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3C3489),
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE24B4A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService.logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
      );
    }
  }

  List<dynamic> watchHistory = [];
  bool isLoading = true;
  int totalSeconds = 0;
  int limitSeconds = 2700;

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
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    setState(() => isLoading = true);
    final history = await ApiService.getWatchHistory(widget.parentId);
    setState(() {
      watchHistory = history;
      isLoading = false;
    });
  }

  // ✅ Convert Cloudinary .mp4 URL → .jpg thumbnail
  String getThumbnailUrl(String? videoUrl) {
    if (videoUrl == null || videoUrl.isEmpty) return '';
    return videoUrl.replaceAll('.mp4', '.jpg');
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')} ${date.hour < 12 ? 'AM' : 'PM'}';
      if (diff.inDays == 1) return 'Yesterday';
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String get topCategory {
    if (watchHistory.isEmpty) return '—';
    final Map<String, int> counts = {};
    for (var item in watchHistory) {
      final cat = item['category'] ?? '';
      counts[cat] = (counts[cat] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  int get todayVideos {
    final today = DateTime.now();
    return watchHistory.where((item) {
      try {
        final date = DateTime.parse(item['watched_at']).toLocal();
        return date.day == today.day &&
            date.month == today.month &&
            date.year == today.year;
      } catch (e) {
        return false;
      }
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    double progress = limitSeconds > 0 ? totalSeconds / limitSeconds : 0;
    if (progress > 1) progress = 1;

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
                          child: Icon(Icons.arrow_back, color: Colors.white70, size: 18),
                        ),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => handleLogout(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Color(0xFF26215C),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.logout, color: Color(0xFFE24B4A), size: 18),
                        ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Parent Dashboard',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text('Monitor your child\'s activity',
                              style: TextStyle(fontSize: 10, color: Color(0xFFAFA9EC))),
                        ],
                      ),
                      Spacer(),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Color(0xFFE24B4A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(child: Text('🦁', style: TextStyle(fontSize: 20))),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Screen time card
                  Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Color(0xFF26215C),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Today's Screen Time",
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white)),
                                Text('Child · Age 5',
                                    style: TextStyle(fontSize: 10, color: Color(0xFFAFA9EC))),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${totalSeconds ~/ 60}',
                                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE24B4A)),
                                      ),
                                      TextSpan(
                                        text: ' min',
                                        style: TextStyle(fontSize: 11, color: Color(0xFFAFA9EC)),
                                      ),
                                    ],
                                  ),
                                ),
                                Text('of ${limitSeconds ~/ 60} min limit',
                                    style: TextStyle(fontSize: 10, color: Color(0xFFAFA9EC))),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Color(0xFF3C3489),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress > 0.8 ? Colors.red : Color(0xFFE24B4A),
                            ),
                            minHeight: 8,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(limitSeconds - totalSeconds) ~/ 60} min remaining',
                              style: TextStyle(fontSize: 10, color: Color(0xFFAFA9EC)),
                            ),
                            GestureDetector(
                              onTap: showLimitDialog,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE24B4A),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('Set limit',
                                    style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500)),
                              ),
                            ),
                          ],
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
                child: Column(
                  children: [

                    // Stats cards
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Color(0xFFEEEDFE), width: 0.5),
                              ),
                              child: Column(
                                children: [
                                  Text('$todayVideos',
                                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3C3489))),
                                  Text('Videos today',
                                      style: TextStyle(fontSize: 9, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Color(0xFFEEEDFE), width: 0.5),
                              ),
                              child: Column(
                                children: [
                                  Text('${watchHistory.length}',
                                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE24B4A))),
                                  Text('Total watched',
                                      style: TextStyle(fontSize: 9, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Color(0xFFEEEDFE), width: 0.5),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    categoryIcons[topCategory] ?? '🎬',
                                    style: TextStyle(fontSize: 22),
                                  ),
                                  Text('Top category',
                                      style: TextStyle(fontSize: 9, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 14),

                    // Watch history header
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Watch History',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF3C3489))),
                          GestureDetector(
                            onTap: loadDashboard,
                            child: Text('Refresh',
                                style: TextStyle(fontSize: 11, color: Color(0xFFE24B4A))),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 10),

                    // Watch history list
                    Expanded(
                      child: isLoading
                          ? Center(child: CircularProgressIndicator(color: Color(0xFFE24B4A)))
                          : watchHistory.isEmpty
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('📺', style: TextStyle(fontSize: 50)),
                          SizedBox(height: 12),
                          Text('No watch history yet',
                              style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
                          SizedBox(height: 6),
                          Text('Videos your child watches will appear here',
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                              textAlign: TextAlign.center),
                        ],
                      )
                          : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: watchHistory.length,
                        itemBuilder: (context, index) {
                          final item = watchHistory[index];
                          final category = item['category'] ?? 'Education';
                          final color = categoryColors[category] ?? Color(0xFF3C3489);
                          final bg = categoryBgColors[category] ?? Color(0xFFEEEDFE);
                          final icon = categoryIcons[category] ?? '🎬';

                          // ✅ Get thumbnail URL from video URL
                          final thumbnailUrl = getThumbnailUrl(item['url']);

                          return Container(
                            margin: EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xFFEEEDFE), width: 0.5),
                            ),
                            child: Row(
                              children: [

                                // ✅ THUMBNAIL — real video thumbnail from Cloudinary
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: thumbnailUrl.isNotEmpty
                                      ? Image.network(
                                    thumbnailUrl,
                                    width: 60,
                                    height: 44,
                                    fit: BoxFit.cover,
                                    // ✅ If thumbnail fails to load, show emoji icon instead
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 60,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: bg,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Text(icon, style: TextStyle(fontSize: 20)),
                                        ),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      // ✅ Show shimmer-like placeholder while loading
                                      return Container(
                                        width: 60,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFEEEDFE),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Color(0xFF3C3489),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                      : Container(
                                    width: 60,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: bg,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(icon, style: TextStyle(fontSize: 20)),
                                    ),
                                  ),
                                ),

                                SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'] ?? 'Unknown Video',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF26215C)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: bg,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(category,
                                                style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w500)),
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            formatDate(item['watched_at'] ?? ''),
                                            style: TextStyle(fontSize: 10, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Safe badge
                                Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFEAF3DE),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.shield, color: Color(0xFF3B6D11), size: 14),
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

  void showLimitDialog() {
    int selectedMinutes = limitSeconds ~/ 60;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Set Daily Limit',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3C3489))),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$selectedMinutes minutes',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE24B4A)),
                ),
                Slider(
                  value: selectedMinutes.toDouble(),
                  min: 15,
                  max: 120,
                  divisions: 21,
                  activeColor: Color(0xFFE24B4A),
                  inactiveColor: Color(0xFFEEEDFE),
                  onChanged: (value) => setDialogState(() => selectedMinutes = value.toInt()),
                ),
                Text('Min: 15 min  ·  Max: 120 min',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newLimit = selectedMinutes * 60;
              setState(() => limitSeconds = newLimit);
              await ScreenTimeService.setLimit(newLimit);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE24B4A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}