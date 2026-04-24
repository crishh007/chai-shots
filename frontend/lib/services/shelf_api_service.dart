import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_constant.dart';

// ─── Base URL ─────────────────────────────────────────────────────────────────
String get _baseUrl => ApiConstants.baseUrl;

// ─── Storage Service ──────────────────────────────────────────────────────────
class StorageService {
  static const _tokenKey = 'auth_token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // ⚠️ Temporary hardcoded token for testing
  // Real app lo login screen tho replace cheyyyali
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_tokenKey);
    if (saved != null && saved.isNotEmpty) return saved;
    // Hardcoded fallback token
    return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2OWQxMzRmNzJiN2QzMWE2NmExOGMyYzgiLCJpYXQiOjE3NzUzNjU1NTgsImV4cCI6MTc3NTk3MDM1OH0.A9QKR08A2kzWF9sxmJNmrmwaS2t1MDZWEfCRp4sDpVU';
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}

// ─── API Service ──────────────────────────────────────────────────────────────
class ApiService {

  // Helper: headers with JWT token
  static Future<Map<String, String>> _headers() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ════════════════════════════════════════════════════════════════
  //  AUTH
  // ════════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = jsonDecode(res.body);
      if (data['token'] != null) {
        await StorageService.saveToken(data['token']);
      }
      return data;
    } catch (e) {
      return {'message': 'Network error: $e'};
    }
  }

  // ════════════════════════════════════════════════════════════════
  //  SAVED APIs → Shelf Page Saved Tab
  //  Backend: /api/saved with episodeId
  // ════════════════════════════════════════════════════════════════

  // GET /api/saved
  static Future<List<dynamic>> getSaved() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/saved'),
        headers: await _headers(),
      );
      print('getSaved: ${res.statusCode} - ${res.body}');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        // Batch backend returns { "saved": [...] }
        if (data is Map && data['saved'] != null) return data['saved'];
        if (data is List) return data;
      }
      return [];
    } catch (e) {
      print('getSaved error: $e');
      return [];
    }
  }

  // POST /api/saved → save an episode
  static Future<bool> saveEpisode({
    required String contentId,
    required String title,
    required String videoUrl,
    required String thumbnailUrl,
    String? seriesName,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/saved'),
        headers: await _headers(),
        body: jsonEncode({
          'contentId': contentId,
          'title': title,
          'videoUrl': videoUrl,
          'thumbnailUrl': thumbnailUrl,
          if (seriesName != null) 'seriesName': seriesName,
        }),
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      print('saveEpisode error: $e');
      return false;
    }
  }

  // DELETE /api/saved/:contentId
  static Future<bool> removeSaved(String contentId) async {
    try {
      final res = await http.delete(
        Uri.parse('$_baseUrl/saved/$contentId'),
        headers: await _headers(),
      );
      return res.statusCode == 200;
    } catch (e) {
      print('removeSaved error: $e');
      return false;
    }
  }

  // DELETE multiple saved items
  static Future<bool> removeMultipleSaved(List<String> episodeIds) async {
    try {
      for (final id in episodeIds) {
        await removeSaved(id);
      }
      return true;
    } catch (e) {
      print('removeMultipleSaved error: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════════
  //  HISTORY APIs → Shelf Page History Tab
  //  Backend: /api/history with episodeId
  // ════════════════════════════════════════════════════════════════

  // GET /api/history
  static Future<List<dynamic>> getHistory() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/history'),
        headers: await _headers(),
      );
      print('getHistory: ${res.statusCode} - ${res.body}');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        // Batch backend returns { "message": "...", "history": [...] }
        if (data is Map && data['history'] != null) return data['history'];
        if (data is List) return data;
      }
      return [];
    } catch (e) {
      print('getHistory error: $e');
      return [];
    }
  }

  // POST /api/history → add episode to history
  static Future<bool> updateHistory({
    required String contentId,
    required String title,
    required String videoUrl,
    required String thumbnailUrl,
    String? seriesName,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/history'),
        headers: await _headers(),
        body: jsonEncode({
          'contentId': contentId,
          'title': title,
          'videoUrl': videoUrl,
          'thumbnailUrl': thumbnailUrl,
          if (seriesName != null) 'seriesName': seriesName,
        }),
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      print('updateHistory error: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════════
  //  EPISODES (for Discover/Search pages)
  // ════════════════════════════════════════════════════════════════

  static Future<List<dynamic>> getEpisodes() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/episodes'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getEpisode(String episodeId) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/episodes/$episodeId'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
      return {};
    } catch (e) {
      return {};
    }
  }

  // ════════════════════════════════════════════════════════════════
  //  SERIES (for Discover page)
  // ════════════════════════════════════════════════════════════════

  static Future<List<dynamic>> getSeries() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/series'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
      return [];
    } catch (e) {
      return [];
    }
  }
}