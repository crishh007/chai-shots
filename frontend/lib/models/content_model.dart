import 'package:flutter/material.dart';

class ContentModel {
  final String id;
  final String title;
  final String rating;
  final String genre;
  final String type;
  final String description;
  final String assetPath;
  final String thumbnail;
  final Color bgColor;

  const ContentModel({
    required this.id,
    required this.title,
    required this.rating,
    required this.genre,
    required this.type,
    required this.description,
    required this.assetPath,
    required this.thumbnail,
    required this.bgColor,
  });

  String get shareUrl => 'https://chaishots.onelink.me/$id';

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    String colorHex = json['bgColor'] ?? 'FF5B4A3F';
    // If the hex color string doesn't include alpha, append 'FF' for 100% opacity
    if (!colorHex.startsWith('FF') && colorHex.length == 6) {
      colorHex = 'FF$colorHex';
    }
    
    // Fallback logic for video URLs
    String backendVideoUrl = json['videoUrl'] ?? '';
    // If videoUrl is a local path on the backend Instead of a full URL,
    // this will be handled in the UI/Service by prepending BaseURL

    return ContentModel(
      id:          json['_id']?.toString() ?? '',
      title:       json['title'] ?? '',
      rating:      json['rating'] ?? 'U',
      genre:       json['genre'] ?? '',
      type:        json['type'] ?? '',
      description: json['description'] ?? '',
      assetPath:   backendVideoUrl,
      thumbnail:   json['thumbnailUrl'] ?? 'https://picsum.photos/seed/${json['_id'] ?? 'thumb'}/300/300',
      bgColor:     Color(int.parse(colorHex, radix: 16)),
    );
  }
}
