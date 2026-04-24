import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalHistoryService {
  static const String _key = 'user_local_history';

  static Future<void> saveToHistory(Map<String, dynamic> videoData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> historyItems = prefs.getStringList(_key) ?? [];
      
      final String id = videoData['_id']?.toString() ?? videoData['id']?.toString() ?? '';
      
      // Ensure we don't save duplicates
      historyItems.removeWhere((item) {
        final map = jsonDecode(item);
        final itemId = map['_id']?.toString() ?? map['id']?.toString() ?? '';
        return itemId == id;
      });

      // Insert at the top
      historyItems.insert(0, jsonEncode(videoData));
      
      await prefs.setStringList(_key, historyItems);
    } catch (e) {
      print("Error saving to history: $e");
    }
  }

  static Future<List<dynamic>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> historyItems = prefs.getStringList(_key) ?? [];
      
      // Map it to the structure expected by ShelfPage:
      // { "episodeId": { ...videoData } }
      return historyItems.map((item) {
        return {
          "episodeId": jsonDecode(item)
        };
      }).toList();
    } catch (e) {
      print("Error getting history: $e");
      return [];
    }
  }
}
