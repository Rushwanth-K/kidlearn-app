import 'package:flutter/material.dart';
import 'dart:async';
import 'online_screen.dart';
import 'offline_screen.dart';
import 'parent_dashboard_screen.dart';
import 'locked_screen.dart';
import '../screen_time_service.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int todaySeconds = 0;
  int limitSeconds = 2700;
  Timer? _homeTimer;

  // ✅ NEW — stores the parent name loaded from secure storage
  String _parentName = 'Parent';

  @override
  void initState() {
    super.initState();
    loadScreenTime();
    _loadParentName(); // ✅ NEW — load name when screen opens
    _homeTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      loadScreenTime();
    });
  }

  @override
  void dispose() {
    _homeTimer?.cancel();
    super.dispose();
  }

  // ✅ NEW — reads parent name saved during register/login
  Future<void> _loadParentName() async {
    final name = await ApiService.getParentName();
    setState(() {
      _parentName = name;
    });
  }

  Future<void> loadScreenTime() async {
    final used = await ScreenTimeService.getTodaySeconds();
    final limit = await ScreenTimeService.getLimit();
    print('Screen time: $used seconds / $limit seconds');
    setState(() {
      todaySeconds = used;
      limitSeconds = limit;
    });
  }

  Future<void> checkAndNavigate(Widget screen) async {
    final locked = await ScreenTimeService.isLimitReached();
    if (locked) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LockedScreen()),
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    }
    loadScreenTime();
  }

  String get screenTimeText {
    final usedMin = todaySeconds ~/ 60;
    final limitMin = limitSeconds ~/ 60;
    return '$usedMin min / $limitMin min';
  }

  double get screenTimeProgress {
    if (limitSeconds == 0) return 0;
    return (todaySeconds / limitSeconds).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF3C3489),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFF3C3489),
        child: SafeArea(
          child: Column(
            children: [

              // ── TOP SECTION ──
              Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  children: [

                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good morning 👋',
                              style: TextStyle(fontSize: 12, color: Color(0xFFAFA9EC)),
                            ),
                            // ✅ CHANGED — was hardcoded 'Hi Arjun!', now dynamic
                            Text(
                              'Hi $_parentName!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Color(0xFFE24B4A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text('🦁', style: TextStyle(fontSize: 22)),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 18),

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
                              Text(
                                "Today's screen time",
                                style: TextStyle(fontSize: 11, color: Color(0xFFAFA9EC)),
                              ),
                              Text(
                                screenTimeText,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: screenTimeProgress,
                              backgroundColor: Color(0xFF3C3489),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                screenTimeProgress > 0.8
                                    ? Colors.red
                                    : Color(0xFFE24B4A),
                              ),
                              minHeight: 6,
                            ),
                          ),
                          SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${(limitSeconds - todaySeconds) ~/ 60} minutes remaining today',
                              style: TextStyle(fontSize: 10, color: Color(0xFFAFA9EC)),
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),

              // ── WHITE CARD SECTION ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFFF8F7FF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        'CHOOSE MODE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                          letterSpacing: 1.2,
                        ),
                      ),

                      SizedBox(height: 12),

                      Row(
                        children: [

                          // Online card
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                await checkAndNavigate(OnlineVideosScreen());
                                loadScreenTime();
                              },
                              child: Container(
                                height: 140,
                                decoration: BoxDecoration(
                                  color: Color(0xFFE24B4A),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                padding: EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: Colors.white24,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text('🌐', style: TextStyle(fontSize: 18)),
                                      ),
                                    ),
                                    Spacer(),
                                    Text('Online',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                                    Text('Curated videos',
                                        style: TextStyle(fontSize: 10, color: Colors.white70)),
                                    SizedBox(height: 6),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white24,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text('● Live',
                                          style: TextStyle(fontSize: 9, color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 10),

                          // Offline card
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                await checkAndNavigate(OfflineVideosScreen());
                                loadScreenTime();
                              },
                              child: Container(
                                height: 140,
                                decoration: BoxDecoration(
                                  color: Color(0xFF3C3489),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                padding: EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: Colors.white12,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text('📂', style: TextStyle(fontSize: 18)),
                                      ),
                                    ),
                                    Spacer(),
                                    Text('Offline',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                                    Text('Parent uploads',
                                        style: TextStyle(fontSize: 10, color: Colors.white60)),
                                    SizedBox(height: 6),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white12,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text('No internet needed',
                                          style: TextStyle(fontSize: 9, color: Color(0xFFCECBF6))),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),

                      SizedBox(height: 10),

                      // School Videos card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Color(0xFF185FA5),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text('🏫', style: TextStyle(fontSize: 18)),
                              ),
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('School Videos',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                                Text('Teacher uploaded lessons',
                                    style: TextStyle(fontSize: 10, color: Colors.white70)),
                              ],
                            ),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('Coming soon',
                                  style: TextStyle(fontSize: 9, color: Color(0xFFB5D4F4))),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 10),

                      // Parent Dashboard button
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ParentDashboardScreen(parentId: 2),
                          ),
                        ).then((_) => loadScreenTime()),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Color(0xFFEEEDFE), width: 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Color(0xFFEEEDFE),
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Center(
                                  child: Text('🛡️', style: TextStyle(fontSize: 16)),
                                ),
                              ),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Parent Dashboard',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF3C3489))),
                                  Text('Watch history · Screen time',
                                      style: TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                              Spacer(),
                              Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}