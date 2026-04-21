import 'package:flutter/foundation.dart';

class LocalVideoMapper {
  static const List<String> _localVideos = [
    'assets/videos/video1.mp4',
    'assets/videos/video2.mp4',
    'assets/videos/video3.mp4',
    'assets/videos/video4.mp4',
    'assets/videos/video5.mp4',
  ];

  static String getLocalVideo(String contentId) {
    if (contentId.isEmpty) return _localVideos[0];
    final int hash = contentId.hashCode.abs();
    return _localVideos[hash % _localVideos.length];
  }

  // Helper to ensure any path is forced to local asset
  static String forceLocalAsset(String originalUrl, String contentId) {
    // If it's a network URL, DO NOT force local asset
    if (originalUrl.startsWith('http')) {
      return originalUrl;
    }
    // If it's already one of our assets, leave it
    if (_localVideos.contains(originalUrl)) {
      return originalUrl;
    }
    return getLocalVideo(contentId);
  }
}
