import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

class ApiService {
  static final String baseUrl = kIsWeb 
      ? 'http://localhost:5000' 
      : (Platform.isAndroid ? 'http://10.0.2.2:5000' : 'http://127.0.0.1:5000');

  // Function to send OTP to the phone number
  Future<Map<String, dynamic>> sendOtp(String phone) async {
    print('Button clicked, calling sendOtp for: $phone');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/otp/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send OTP: ${response.body}');
      }
    } catch (e) {
      throw Exception('API not reachable: $e');
    }
  }

  // Function to verify OTP
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/otp/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'otp': otp}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Verification failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// GET /api/profile — fetches current user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/profile'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Server returned ${response.statusCode}");
      }
    } catch (e) {
      // Mock fallback when backend is unreachable
      return {
        "name": "Test User",
        "email": "test@gmail.com",
        "phone": "9999999999"
      };
    }
  }

  static Future<List<dynamic>> getSeries() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/series'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load series');
      }
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> getEpisodesBySeries(String seriesId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/episodes/series/$seriesId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load episodes');
      }
    } catch (e) {
      return [];
    }
  }
}
