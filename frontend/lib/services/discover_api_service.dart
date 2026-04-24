import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/content_model.dart';
import 'api_constant.dart';

class ApiService {
  // Use the isolated ApiConstants for flexibility across Environments
  static String get _baseUrl => ApiConstants.baseUrl;

  /// Fetch all active content objects sequentially ordered by latest from MongoDB
  static Future<List<ContentModel>> fetchContent() async {
    debugPrint("🟡 Attempting to connect to $_baseUrl/discover");
    final url = '$_baseUrl/discover';
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
          
      print("API URL: $url");
      print("REQUEST: ");
      print("RESPONSE: ${response.body}");
      print("STATUS CODE: ${response.statusCode}");

      if (response.statusCode == 200) {
        debugPrint("🟢 API Success: Response received");
        final List<dynamic> data = json.decode(response.body);
        print("Parsed Data: $data");
        return data.map((item) => ContentModel.fromJson(item)).toList();
      } else {
        debugPrint('🔴 API Failed. Status Code: ${response.statusCode}');
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('🔴 API Connection Exception: $e');
      throw Exception("Connection failed. Check your Backend or BaseURL. Details: $e");
    }
  }

  /// Send a clap to the backend
  static Future<bool> sendClap({
    required String contentId,
    required String personName,
    required String role,
  }) async {
    try {
      final url = '$_baseUrl/claps';
      final body = json.encode({
        'contentId': contentId,
        'personName': personName,
        'role': role,
      });

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 10));
          
      print("API URL: $url");
      print("REQUEST: $body");
      print("RESPONSE: ${response.body}");
      print("STATUS CODE: ${response.statusCode}");
      print("Parsed Data: ${json.decode(response.body)}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('sendClap Exception: $e');
      return false;
    }
  }

  /// Get claps for content (migrated from old api_service)
  static Future<List<Map<String, dynamic>>> getClaps(String contentId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/claps/$contentId'))
          .timeout(const Duration(seconds: 10));
          
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting claps: $e');
      return [];
    }
  }
}