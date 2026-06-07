import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// This file handles ALL communication between Flutter and Node.js
// Think of it as the translator between your app and your server

class ApiService {

  // Your Node.js server address
  static const String baseUrl = 'https://kidlearn-backend-syxy.onrender.com';

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

  // ── SAVE PARENT NAME ──  ✅ NEW
  static Future<void> saveParentName(String name) async {
    await _storage.write(key: 'parent_name', value: name);
  }

  // ── GET PARENT NAME ──  ✅ NEW
  static Future<String> getParentName() async {
    return await _storage.read(key: 'parent_name') ?? 'Parent';
  }
  // ── SAVE PARENT ID ──
  static Future<void> saveParentId(int id) async {
    await _storage.write(key: 'parent_id', value: id.toString());
  }

// ── GET PARENT ID ──
  static Future<int> getParentId() async {
    final id = await _storage.read(key: 'parent_id');
    return int.tryParse(id ?? '0') ?? 0;
  }
  // ── SAVE CHILD ID ──
  static Future<void> saveChildId(int id) async {
    await _storage.write(key: 'child_id', value: id.toString());
  }

// ── GET CHILD ID ──
  static Future<int> getChildId() async {
    final id = await _storage.read(key: 'child_id');
    return int.tryParse(id ?? '1') ?? 1;
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
      final data = jsonDecode(response.body);

      // ✅ NEW — save name when register succeeds
      if (data['error'] == null) {
        await saveParentName(name);
      }
      if (data['parentId'] != null) {
        await saveParentId(data['parentId']);
      }

      return data;
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

        // ✅ NEW — save name from login response
        if (data['parent'] != null && data['parent']['name'] != null) {
          await saveParentName(data['parent']['name']);
        }
      }
      if (data['parent'] != null && data['parent']['id'] != null) {
        await saveParentId(data['parent']['id']);
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