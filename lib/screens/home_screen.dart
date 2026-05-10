import 'package:flutter/material.dart';
import 'online_screen.dart';
import 'offline_screen.dart';
import 'parent_dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF7F77DD),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                'Good morning!',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),

              Text(
                'Hi Sudha 👋',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 16),

              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF534AB7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.white70, size: 16),
                    SizedBox(width: 8),
                    Text(
                      "Today's screen time: ",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      '23 min of 45 min',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              Text(
                'CHOOSE MODE',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: 12),

              Row(
                children: [

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OnlineVideosScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 140,
                        decoration: BoxDecoration(
                          color: Color(0xFF1D9E75),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_circle, color: Colors.white, size: 40),
                            SizedBox(height: 8),
                            Text('Online', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text('Curated videos', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OfflineVideosScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 140,
                        decoration: BoxDecoration(
                          color: Color(0xFFBA7517),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.download, color: Colors.white, size: 40),
                            SizedBox(height: 8),
                            Text('Offline', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text('Parent uploads', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),

                ],
              ),

              SizedBox(height: 24),

              // ── PARENT DASHBOARD BUTTON ──
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ParentDashboardScreen(parentId: 1),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Color(0xFF534AB7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Parent Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.chevron_right, color: Colors.white70, size: 20),
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