import 'package:flutter/material.dart';
import '../screen_time_service.dart';

class LockedScreen extends StatefulWidget {
  const LockedScreen({super.key});

  @override
  State<LockedScreen> createState() => _LockedScreenState();
}

class _LockedScreenState extends State<LockedScreen> {

  final pinController = TextEditingController();
  bool showPinInput = false;
  bool wrongPin = false;

  // Parent PIN — later this should come from database
  static const String parentPin = '0000';

  void checkPin() {
    if (pinController.text == parentPin) {
      // Reset screen time and unlock
      ScreenTimeService.resetToday();
      Navigator.pop(context);
    } else {
      setState(() => wrongPin = true);
      pinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF3C3489),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // Lock icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Color(0xFFE24B4A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.lock, color: Colors.white, size: 40),
                ),

                SizedBox(height: 24),

                Text(
                  'Screen Time Limit Reached!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 12),

                Text(
                  "You have watched enough videos for today.\nCome back tomorrow! 🌟",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFAFA9EC),
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 40),

                if (!showPinInput) ...[
                  // Parent unlock button
                  GestureDetector(
                    onTap: () => setState(() => showPinInput = true),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Color(0xFF26215C),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield, color: Color(0xFFAFA9EC), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Parent Unlock',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[

                  // PIN input
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [

                        Text(
                          'Enter Parent PIN',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3C3489),
                          ),
                        ),

                        SizedBox(height: 16),

                        TextField(
                          controller: pinController,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          maxLength: 4,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            letterSpacing: 12,
                            color: Color(0xFF3C3489),
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: '• • • •',
                            hintStyle: TextStyle(
                              fontSize: 24,
                              letterSpacing: 12,
                              color: Colors.grey.shade300,
                            ),
                            filled: true,
                            fillColor: Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) {
                            if (value.length == 4) checkPin();
                          },
                        ),

                        if (wrongPin) ...[
                          SizedBox(height: 8),
                          Text(
                            'Wrong PIN. Try again.',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ],

                        SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  showPinInput = false;
                                  wrongPin = false;
                                  pinController.clear();
                                }),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey, fontSize: 13),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: checkPin,
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFFE24B4A), Color(0xFF3C3489)],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Unlock',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ],

              ],
            ),
          ),
        ),
      ),
    );
  }
}