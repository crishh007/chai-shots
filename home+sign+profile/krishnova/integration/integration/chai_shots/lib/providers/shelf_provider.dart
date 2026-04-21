import 'package:flutter/material.dart';
import '../models/content_model.dart';
import '../services/local_history_service.dart';
import '../services/local_saved_service.dart';
import '../services/shelf_api_service.dart' as ShelfApi;
import 'dart:convert';

class ShelfProvider extends ChangeNotifier {
  List<dynamic> _history = [];
  List<dynamic> _saved = [];

  List<dynamic> get history => _history;
  List<dynamic> get saved => _saved;

  ShelfProvider() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _history = await LocalHistoryService.getHistory();
    _saved = await LocalSavedService.getSaved();
    notifyListeners();
  }

  Future<void> refresh() async {
    await _loadInitialData();
  }

  Future<void> addToHistory(Map<String, dynamic> videoData) async {
    // Check if already top of history to prevent redundant triggers
    if (_history.isNotEmpty) {
      final top = _history.first;
      final ep = top['episodeId'] ?? top['contentId'];
      final String topId = (ep is Map ? ep['_id']?.toString() : ep?.toString()) ?? '';
      final String newId = videoData['_id']?.toString() ?? videoData['id']?.toString() ?? '';
      if (topId == newId) return;
    }

    await LocalHistoryService.saveToHistory(videoData);
    
    // Fire API call silently in background
    ShelfApi.ApiService.updateHistory(
      contentId: videoData['_id']?.toString() ?? videoData['id']?.toString() ?? '',
      title: videoData['title'] ?? '',
      videoUrl: videoData['videoUrl'] ?? videoData['assetPath'] ?? '',
      thumbnailUrl: videoData['thumbnailUrl'] ?? videoData['thumbnail'] ?? '',
    );
    
    _history = await LocalHistoryService.getHistory();
    notifyListeners();
  }

  Future<void> toggleSaved(Map<String, dynamic> videoData) async {
    final String id = videoData['_id']?.toString() ?? videoData['id']?.toString() ?? '';
    final bool isSaved = _saved.any((item) {
      final ep = item['contentId'] ?? item['episodeId'];
      final itemId = (ep is Map ? ep['_id']?.toString() : ep?.toString()) ?? '';
      return itemId == id;
    });

    if (isSaved) {
      await LocalSavedService.removeFromSaved(id);
      ShelfApi.ApiService.removeSaved(id);
    } else {
      await LocalSavedService.saveToSaved(videoData);
      ShelfApi.ApiService.saveEpisode(
        contentId: id,
        title: videoData['title'] ?? '',
        videoUrl: videoData['videoUrl'] ?? videoData['assetPath'] ?? '',
        thumbnailUrl: videoData['thumbnailUrl'] ?? videoData['thumbnail'] ?? '',
      );
    }
    
    _saved = await LocalSavedService.getSaved();
    notifyListeners();
  }

  bool isVideoSaved(String id) {
    return _saved.any((item) {
      final ep = item['contentId'] ?? item['episodeId'];
      final itemId = (ep is Map ? ep['_id']?.toString() : ep?.toString()) ?? '';
      return itemId == id;
    });
  }
}
