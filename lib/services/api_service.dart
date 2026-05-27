import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// This file handles ALL communication between Flutter and Node.js
// Think of it as the translator between your app and your server

class ApiService {

  // Your Node.js server address
  // We use 10.0.2.2 for emulator, but for real phone we use your laptop IP
  static const String baseUrl = 'https://parole-scant-undertook.ngrok-free.dev';

  // Secure storage to save JWT token on the phone
  static const _storage = FlutterSecureStorage();

  // ── SAVE TOKEN ──
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  // ── GET TOKEN ──
  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // ── DELETE TOKEN (logout) ──
  static Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  // ── REGISTER ──
  static Future<Map<String, dynamic>> register(String name, String email,
      String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Cannot connect to server. Check your connection.'};
    }
  }

  // ── LOGIN ──
  static Future<Map<String, dynamic>> login(String email,
      String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      // If login successful, save the token automatically
      if (data['token'] != null) {
        await saveToken(data['token']);
      }

      return data;
    } catch (e) {
      return {'error': 'Cannot connect to server. Check your connection.'};
    }
  }

  // ── GET VIDEOS ──
  static Future<List<dynamic>> getVideos({String? category, int? age}) async {
    try {
      String url = '$baseUrl/api/videos';
      List<String> params = [];
      if (category != null && category != 'All') params.add(
          'category=$category');
      if (age != null) params.add('age=$age');
      if (params.isNotEmpty) url += '?${params.join('&')}';

      final token = await getToken();
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return [];
    }
  }

// ── GET WATCH HISTORY ──
  static Future<List<dynamic>> getWatchHistory(int parentId) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/videos/history/$parentId'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return [];
    }
  }
  // ── ADD CHILD ──
  static Future<Map<String, dynamic>> addChild({
    required int parentId,
    required String name,
    required int age,
    required String interests,
    required int avatar,
    String pin = '0000',
  }) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/api/children/add'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'parent_id': parentId,
          'name': name,
          'age': age,
          'pin': pin,
          'interests': interests,
          'avatar': avatar,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Cannot connect to server'};
    }
  }

// ── GET CHILDREN ──
  static Future<List<dynamic>> getChildren(int parentId) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/children/$parentId'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return [];
    }
  }
  // ── LOG WATCH HISTORY ──
  static Future<void> logWatchHistory({
    required int childId,
    required int videoId,
    int durationWatched = 0,
  }) async {
    try {
      final token = await getToken();
      await http.post(
        Uri.parse('$baseUrl/api/videos/history'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'child_id': childId,
          'video_id': videoId,
          'duration_watched': durationWatched,
        }),
      );
    } catch (e) {
      debugPrint('Watch history error: $e');
    }
  }
  // ── LOGOUT ──
  static Future<void> logout() async {
    await deleteToken();
  }
}