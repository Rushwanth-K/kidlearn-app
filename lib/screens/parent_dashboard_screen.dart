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
        title: Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3C3489))),
        content: Text('Are you sure you want to logout?', style: TextStyle(fontSize: 13, color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE24B4A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.logout();
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
    }
  }

  List<dynamic> watchHistory = [];
  bool isLoading = true;
  int totalSeconds = 0;
  int limitSeconds = 2700;
  String _childName = 'Child';
  int _childAge = 0;

  // ✅ NEW — selected tab for bottom section
  int _selectedTab = 0; // 0=History, 1=Categories, 2=Weekly

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
    final results = await Future.wait([
      ApiService.getWatchHistory(widget.parentId),
      ApiService.getChildren(widget.parentId),
    ]);
    final history = results[0] as List<dynamic>;
    final children = results[1] as List<dynamic>;
    final used = await ScreenTimeService.getTodaySeconds();
    final limit = await ScreenTimeService.getLimit();
    setState(() {
      watchHistory = history;
      isLoading = false;
      totalSeconds = used;
      limitSeconds = limit;
      if (children.isNotEmpty) {
        _childName = children[0]['name'] ?? 'Child';
        _childAge = children[0]['age'] ?? 0;
      }
    });
  }

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
    } catch (e) { return dateStr; }
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
        return date.day == today.day && date.month == today.month && date.year == today.year;
      } catch (e) { return false; }
    }).length;
  }

  // ✅ NEW — category breakdown counts
  Map<String, int> get categoryCounts {
    final Map<String, int> counts = {};
    for (var item in watchHistory) {
      final cat = item['category'] ?? 'Other';
      counts[cat] = (counts[cat] ?? 0) + 1;
    }
    return counts;
  }

  // ✅ NEW — weekly videos count (last 7 days)
  Map<String, int> get weeklyData {
    final Map<String, int> data = {};
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (var d in days) data[d] = 0;

    final now = DateTime.now();
    for (var item in watchHistory) {
      try {
        final date = DateTime.parse(item['watched_at']).toLocal();
        final diff = now.difference(date).inDays;
        if (diff < 7) {
          final dayName = days[date.weekday - 1];
          data[dayName] = (data[dayName] ?? 0) + 1;
        }
      } catch (e) {}
    }
    return data;
  }

  // ✅ NEW — watch streak calculation
  int get watchStreak {
    if (watchHistory.isEmpty) return 0;
    final Set<String> watchedDates = {};
    for (var item in watchHistory) {
      try {
        final date = DateTime.parse(item['watched_at']).toLocal();
        watchedDates.add('${date.year}-${date.month}-${date.day}');
      } catch (e) {}
    }
    int streak = 0;
    DateTime current = DateTime.now();
    while (true) {
      final key = '${current.year}-${current.month}-${current.day}';
      if (watchedDates.contains(key)) {
        streak++;
        current = current.subtract(Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
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
                        child: Container(width: 38, height: 38, decoration: BoxDecoration(color: Color(0xFF26215C), borderRadius: BorderRadius.circular(10)),
                            child: Icon(Icons.arrow_back, color: Colors.white70, size: 18)),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => handleLogout(),
                        child: Container(width: 38, height: 38, decoration: BoxDecoration(color: Color(0xFF26215C), borderRadius: BorderRadius.circular(10)),
                            child: Icon(Icons.logout, color: Color(0xFFE24B4A), size: 18)),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Parent Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text('Monitor your child\'s activity', style: TextStyle(fontSize: 10, color: Color(0xFFAFA9EC))),
                        ],
                      ),
                      Spacer(),
                      Container(width: 38, height: 38, decoration: BoxDecoration(color: Color(0xFFE24B4A), borderRadius: BorderRadius.circular(10)),
                          child: Center(child: Text('🦁', style: TextStyle(fontSize: 20)))),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Screen time card
                  Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Color(0xFF26215C), borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Today's Screen Time", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white)),
                                Text(_childAge > 0 ? '$_childName · Age $_childAge' : _childName,
                                    style: TextStyle(fontSize: 10, color: Color(0xFFAFA9EC))),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                RichText(
                                  text: TextSpan(children: [
                                    TextSpan(text: '${totalSeconds ~/ 60}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE24B4A))),
                                    TextSpan(text: ' min', style: TextStyle(fontSize: 11, color: Color(0xFFAFA9EC))),
                                  ]),
                                ),
                                Text('of ${limitSeconds ~/ 60} min limit', style: TextStyle(fontSize: 10, color: Color(0xFFAFA9EC))),
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
                            valueColor: AlwaysStoppedAnimation<Color>(progress > 0.8 ? Colors.red : Color(0xFFE24B4A)),
                            minHeight: 8,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${(limitSeconds - totalSeconds) ~/ 60} min remaining', style: TextStyle(fontSize: 10, color: Color(0xFFAFA9EC))),
                            GestureDetector(
                              onTap: showLimitDialog,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: Color(0xFFE24B4A), borderRadius: BorderRadius.circular(20)),
                                child: Text('Set limit', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500)),
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
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                ),
                child: Column(
                  children: [

                    // ✅ Stats cards row
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        children: [
                          Expanded(child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Color(0xFFEEEDFE), width: 0.5)),
                            child: Column(children: [
                              Text('$todayVideos', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3C3489))),
                              Text('Today', style: TextStyle(fontSize: 9, color: Colors.grey)),
                            ]),
                          )),
                          SizedBox(width: 8),
                          Expanded(child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Color(0xFFEEEDFE), width: 0.5)),
                            child: Column(children: [
                              Text('${watchHistory.length}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE24B4A))),
                              Text('Total', style: TextStyle(fontSize: 9, color: Colors.grey)),
                            ]),
                          )),
                          SizedBox(width: 8),
                          // ✅ NEW — Watch streak card
                          Expanded(child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Color(0xFFEEEDFE), width: 0.5)),
                            child: Column(children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('🔥', style: TextStyle(fontSize: 16)),
                                  SizedBox(width: 2),
                                  Text('$watchStreak', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE24B4A))),
                                ],
                              ),
                              Text('Day streak', style: TextStyle(fontSize: 9, color: Colors.grey)),
                            ]),
                          )),
                        ],
                      ),
                    ),

                    SizedBox(height: 14),

                    // ✅ NEW — Tab switcher
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(color: Color(0xFFEEEDFE), borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.all(4),
                        child: Row(
                          children: [
                            _buildTab('History', 0),
                            _buildTab('Categories', 1),
                            _buildTab('Weekly', 2),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    // ✅ Tab content
                    Expanded(
                      child: isLoading
                          ? Center(child: CircularProgressIndicator(color: Color(0xFFE24B4A)))
                          : _selectedTab == 0
                          ? _buildHistoryTab()
                          : _selectedTab == 1
                          ? _buildCategoriesTab()
                          : _buildWeeklyTab(),
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

  // ✅ Tab button builder
  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFE24B4A) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.white : Color(0xFF3C3489),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ HISTORY TAB — existing watch history
  Widget _buildHistoryTab() {
    if (watchHistory.isEmpty) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('📺', style: TextStyle(fontSize: 50)),
        SizedBox(height: 12),
        Text('No watch history yet', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
        SizedBox(height: 6),
        Text('Videos your child watches will appear here', style: TextStyle(color: Colors.grey.shade400, fontSize: 12), textAlign: TextAlign.center),
      ]);
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: watchHistory.length,
      itemBuilder: (context, index) {
        final item = watchHistory[index];
        final category = item['category'] ?? 'Education';
        final color = categoryColors[category] ?? Color(0xFF3C3489);
        final bg = categoryBgColors[category] ?? Color(0xFFEEEDFE);
        final icon = categoryIcons[category] ?? '🎬';
        final thumbnailUrl = getThumbnailUrl(item['url']);

        return Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Color(0xFFEEEDFE), width: 0.5)),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: thumbnailUrl.isNotEmpty
                    ? Image.network(thumbnailUrl, width: 60, height: 44, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60, height: 44,
                    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text(icon, style: TextStyle(fontSize: 20))),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 60, height: 44,
                      decoration: BoxDecoration(color: Color(0xFFEEEDFE), borderRadius: BorderRadius.circular(10)),
                      child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3C3489)))),
                    );
                  },
                )
                    : Container(
                  width: 60, height: 44,
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Text(icon, style: TextStyle(fontSize: 20))),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title'] ?? 'Unknown Video', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF26215C)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 4),
                    Row(children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
                        child: Text(category, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w500)),
                      ),
                      SizedBox(width: 6),
                      Text(formatDate(item['watched_at'] ?? ''), style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ]),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(color: Color(0xFFEAF3DE), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.shield, color: Color(0xFF3B6D11), size: 14),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ NEW — CATEGORIES TAB
  Widget _buildCategoriesTab() {
    final counts = categoryCounts;
    if (counts.isEmpty) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('📊', style: TextStyle(fontSize: 50)),
        SizedBox(height: 12),
        Text('No data yet', style: TextStyle(color: Colors.grey, fontSize: 14)),
      ]);
    }

    final total = counts.values.fold(0, (a, b) => a + b);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Content breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF3C3489))),
          SizedBox(height: 4),
          Text('Based on ${watchHistory.length} videos watched', style: TextStyle(fontSize: 11, color: Colors.grey)),
          SizedBox(height: 16),

          ...counts.entries.map((entry) {
            final cat = entry.key;
            final count = entry.value;
            final percent = total > 0 ? count / total : 0.0;
            final color = categoryColors[cat] ?? Color(0xFF3C3489);
            final bg = categoryBgColors[cat] ?? Color(0xFFEEEDFE);
            final icon = categoryIcons[cat] ?? '🎬';

            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFEEEDFE), width: 0.5),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                        child: Center(child: Text(icon, style: TextStyle(fontSize: 18))),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cat, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF26215C))),
                            Text('$count video${count != 1 ? 's' : ''}', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Text('${(percent * 100).toStringAsFixed(0)}%',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                    ],
                  ),
                  SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent,
                      backgroundColor: bg,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ✅ NEW — WEEKLY TAB
  Widget _buildWeeklyTab() {
    final data = weeklyData;
    final maxVal = data.values.fold(0, (a, b) => a > b ? a : b);
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][DateTime.now().weekday - 1];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This week\'s activity', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF3C3489))),
          SizedBox(height: 4),
          Text('Videos watched per day', style: TextStyle(fontSize: 11, color: Colors.grey)),
          SizedBox(height: 20),

          // ✅ Bar chart
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Color(0xFFEEEDFE), width: 0.5),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: days.map((day) {
                      final count = data[day] ?? 0;
                      final barHeight = maxVal > 0 ? (count / maxVal) * 100 : 0.0;
                      final isToday = day == today;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (count > 0)
                            Text('$count', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w500)),
                          SizedBox(height: 4),
                          Container(
                            width: 28,
                            height: barHeight > 0 ? barHeight : 6,
                            decoration: BoxDecoration(
                              color: isToday
                                  ? Color(0xFFE24B4A)
                                  : count > 0
                                  ? Color(0xFF3C3489)
                                  : Color(0xFFEEEDFE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: days.map((day) {
                    final isToday = day == today;
                    return SizedBox(
                      width: 28,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          color: isToday ? Color(0xFFE24B4A) : Colors.grey,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // ✅ Weekly summary
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Color(0xFFEEEDFE), width: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(children: [
                  Text('${data.values.fold(0, (a, b) => a + b)}',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3C3489))),
                  Text('This week', style: TextStyle(fontSize: 9, color: Colors.grey)),
                ]),
                Container(width: 1, height: 40, color: Color(0xFFEEEDFE)),
                Column(children: [
                  Text('${data.values.where((v) => v > 0).length}',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE24B4A))),
                  Text('Active days', style: TextStyle(fontSize: 9, color: Colors.grey)),
                ]),
                Container(width: 1, height: 40, color: Color(0xFFEEEDFE)),
                Column(children: [
                  Row(children: [
                    Text('🔥', style: TextStyle(fontSize: 16)),
                    Text('$watchStreak',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE24B4A))),
                  ]),
                  Text('Day streak', style: TextStyle(fontSize: 9, color: Colors.grey)),
                ]),
              ],
            ),
          ),

        ],
      ),
    );
  }

  void showLimitDialog() {
    int selectedMinutes = limitSeconds ~/ 60;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Set Daily Limit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3C3489))),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$selectedMinutes minutes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE24B4A))),
                Slider(
                  value: selectedMinutes.toDouble(), min: 15, max: 120, divisions: 21,
                  activeColor: Color(0xFFE24B4A), inactiveColor: Color(0xFFEEEDFE),
                  onChanged: (value) => setDialogState(() => selectedMinutes = value.toInt()),
                ),
                Text('Min: 15 min  ·  Max: 120 min', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              final newLimit = selectedMinutes * 60;
              setState(() => limitSeconds = newLimit);
              await ScreenTimeService.setLimit(newLimit);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE24B4A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}