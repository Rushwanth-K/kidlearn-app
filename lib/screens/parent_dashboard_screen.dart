import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ParentDashboardScreen extends StatefulWidget {
  final int parentId;
  const ParentDashboardScreen({super.key, required this.parentId});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {

  List<dynamic> watchHistory = [];
  bool isLoading = true;
  int totalSeconds = 0;
  int limitSeconds = 2700; // 45 minutes default

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    setState(() => isLoading = true);

    // Load watch history
    final history = await ApiService.getWatchHistory(widget.parentId);

    setState(() {
      watchHistory = history;
      isLoading = false;
    });
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}m ${secs}s';
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case 'Education':  return Color(0xFF185FA5);
      case 'Creativity': return Color(0xFF993556);
      case 'Nature':     return Color(0xFF3B6D11);
      case 'Stories':    return Color(0xFF854F0B);
      case 'Music':      return Color(0xFF993C1D);
      default:           return Color(0xFF1D9E75);
    }
  }

  @override
  Widget build(BuildContext context) {

    double progress = limitSeconds > 0 ? totalSeconds / limitSeconds : 0;
    if (progress > 1) progress = 1;

    return Scaffold(
      backgroundColor: Color(0xFF7F77DD),
      body: SafeArea(
        child: Column(
          children: [

            // ── HEADER ──
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(0xFF534AB7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Parent Dashboard',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Screen time card
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF534AB7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Today's Screen Time",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${formatTime(totalSeconds)} / ${formatTime(limitSeconds)}',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10),

                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress > 0.8 ? Colors.red : Colors.white,
                            ),
                            minHeight: 8,
                          ),
                        ),

                        SizedBox(height: 12),

                        // Set limit button
                        GestureDetector(
                          onTap: () => showLimitDialog(),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Set daily limit',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),

                ],
              ),
            ),

            // ── WATCH HISTORY ──
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: Text(
                        'Watch History',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3C3489),
                        ),
                      ),
                    ),

                    Expanded(
                      child: isLoading
                          ? Center(child: CircularProgressIndicator(color: Color(0xFF7F77DD)))
                          : watchHistory.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 60, color: Colors.grey.shade300),
                            SizedBox(height: 16),
                            Text(
                              'No watch history yet',
                              style: TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                            Text(
                              'Videos watched will appear here',
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                          : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        itemCount: watchHistory.length,
                        itemBuilder: (context, index) {
                          final item = watchHistory[index];
                          final color = getCategoryColor(item['category'] ?? '');

                          return Container(
                            margin: EdgeInsets.only(bottom: 10),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [

                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.play_circle, color: color, size: 22),
                                ),

                                SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'] ?? 'Unknown',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              item['category'] ?? '',
                                              style: TextStyle(fontSize: 9, color: color),
                                            ),
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            item['child_name'] ?? '',
                                            style: TextStyle(fontSize: 10, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        formatDate(item['watched_at'] ?? ''),
                                        style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                                      ),
                                    ],
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

  void showLimitDialog() {
    int selectedMinutes = limitSeconds ~/ 60;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Daily Screen Time Limit'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$selectedMinutes minutes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF7F77DD))),
                Slider(
                  value: selectedMinutes.toDouble(),
                  min: 15,
                  max: 120,
                  divisions: 21,
                  activeColor: Color(0xFF7F77DD),
                  onChanged: (value) {
                    setDialogState(() => selectedMinutes = value.toInt());
                  },
                ),
                Text('Min: 15 min  |  Max: 120 min', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => limitSeconds = selectedMinutes * 60);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF7F77DD)),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}