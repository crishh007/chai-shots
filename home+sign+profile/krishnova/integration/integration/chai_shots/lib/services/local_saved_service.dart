import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalSavedService {
  static const String _key = 'user_local_saved';

  static Future<void> saveToSaved(Map<String, dynamic> videoData) async {
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
      print("Error saving to saved: $e");
    }
  }

  static Future<void> removeFromSaved(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> savedItems = prefs.getStringList(_key) ?? [];
      
      savedItems.removeWhere((item) {
        final map = jsonDecode(item);
        final itemId = map['_id']?.toString() ?? map['id']?.toString() ?? '';
        return itemId == id;
      });
      
      await prefs.setStringList(_key, savedItems);
    } catch (e) {
      print("Error removing from saved: $e");
    }
  }

  static Future<List<dynamic>> getSaved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> savedItems = prefs.getStringList(_key) ?? [];
      
      // Map it to the structure expected by ShelfPage:
      // { "episodeId": { ...videoData } }
      return savedItems.map((item) {
        return {
          "episodeId": jsonDecode(item)
        };
      }).toList();
    } catch (e) {
      print("Error getting saved: $e");
      return [];
    }
  }
}
