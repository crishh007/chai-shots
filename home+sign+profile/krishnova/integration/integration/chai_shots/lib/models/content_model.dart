import 'package:flutter/material.dart';

class EpisodeModel {
  final String id;
  final String title;
  final String videoUrl;

  const EpisodeModel({
    required this.id,
    required this.title,
    required this.videoUrl,
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    return EpisodeModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      videoUrl: json['videoUrl'] ?? json['video_url'] ?? '',
    );
  }
}

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
    if (!colorHex.startsWith('FF') && colorHex.length == 6) {
      colorHex = 'FF$colorHex';
    }
    
    return ContentModel(
      id:          json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title:       json['title'] ?? '',
      rating:      json['rating'] ?? 'U',
      genre:       json['genre'] ?? '',
      type:        json['type'] ?? '',
      description: json['description'] ?? '',
      assetPath:   json['videoUrl'] ?? json['video_url'] ?? '',
      thumbnail:   json['thumbnail'] ?? json['thumbnailUrl'] ?? '',
      bgColor:     Color(int.parse(colorHex, radix: 16)),
    );
  }
}
