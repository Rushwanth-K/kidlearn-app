import 'package:shared_preferences/shared_preferences.dart';

class ScreenTimeService {

  static const String _keySeconds = 'screen_time_seconds';
  static const String _keyLimit   = 'screen_time_limit';
  static const String _keyDate    = 'screen_time_date';

  // Get today's used seconds
  static Future<int> getTodaySeconds() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(_keyDate) ?? '';
    final today = DateTime.now().toIso8601String().split('T')[0];

    // Reset if new day
    if (savedDate != today) {
      await prefs.setString(_keyDate, today);
      await prefs.setInt(_keySeconds, 0);
      return 0;
    }

    return prefs.getInt(_keySeconds) ?? 0;
  }

  // Add seconds to today's count ← THIS WAS MISSING
  static Future<void> addSeconds(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString(_keyDate, today);
    final current = prefs.getInt(_keySeconds) ?? 0;
    final newValue = current + seconds;
    await prefs.setInt(_keySeconds, newValue);
    print('Screen time saved: $newValue seconds');
  }

  // Get daily limit in seconds
  static Future<int> getLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLimit) ?? 2700; // 45 minutes default
  }

  // Set daily limit
  static Future<void> setLimit(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLimit, seconds);
  }

  // Check if limit is reached
  static Future<bool> isLimitReached() async {
    final used = await getTodaySeconds();
    final limit = await getLimit();
    return used >= limit;
  }

  // Reset today's time — parent can reset after unlock
  static Future<void> resetToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySeconds, 0);
  }
}