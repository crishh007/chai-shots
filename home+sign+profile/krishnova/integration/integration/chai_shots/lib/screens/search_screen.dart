import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_constant.dart';
import 'shelf_video_player_page.dart';
import 'series_screen.dart';
import 'package:provider/provider.dart';
import '../providers/shelf_provider.dart';
class OttSearchScreen extends StatefulWidget {
  const OttSearchScreen({super.key});

  @override
  State<OttSearchScreen> createState() => _OttSearchScreenState();
}

class _OttSearchScreenState extends State<OttSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    print("SEARCH SCREEN INITIALIZED");
  }

  // 🎬 FIXED POPULAR SEARCHES (1st: Veena, 2nd: Panimanishiki Padipoya)
  final List<Map<String, String>> _popularSearches = [
    {
      "title": "Veena",
      "image":
          "https://res.cloudinary.com/dp6dikfcb/image/upload/v1774961530/veena_emuxir.jpg",
    },
    {
      "title": "Panimanishiki Padipoya",
      "image":
          "https://res.cloudinary.com/dp6dikfcb/image/upload/v1775062479/pani_nslbzp.jpg",
    },
  ];

  final List<Map<String, String>> _popularGenres = [
    {"name": "Drama", "image": "assets/images/drama.jpg"},
    {"name": "Comedy", "image": "assets/images/comedy.jpg"},
    {"name": "Rom-Com", "image": "assets/images/romcom.jpg"},
    {"name": "Thriller", "image": "assets/images/thriller.jpg"},
  ];

  final List<String> _recommendationImages = [
    "https://picsum.photos/300/450?random=5",
    "https://picsum.photos/300/450?random=6",
    "https://picsum.photos/300/450?random=7",
    "https://picsum.photos/300/450?random=8",
  ];

  // 🔍 SEARCH INPUT
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        setState(() {
          _isSearching = false;
          _searchResults = [];
        });
      }
    });
  }

  // 🔥 CALL BACKEND
  Future<void> _performSearch(String query) async {
    // 🧹 CLEAR PREVIOUS RESULTS BEFORE NEW SEARCH
    setState(() {
      _isLoading = true;
      _isSearching = true;
      _searchResults = [];
    });

    try {
      print("PERFORMING SEARCH FOR: $query");
      final results = await SearchService.searchVideos(query);

      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      print("SEARCH ERROR: $e");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _searchResults = [];
      });
    }
  }

  void _playVideo(dynamic item) {
    String url = item['videoUrl'] ?? item['assetPath'] ?? '';
    print("DEBUG: Video URL coming from backend before playing: $url");
    if (url.isEmpty) url = 'assets/videos/video1.mp4';
    
    String id = item['id']?.toString() ?? item['_id']?.toString() ?? '';
    String title = item['title'] ?? 'Title';
    String thumbnailUrl = item['thumbnailUrl'] ?? item['image'] ?? '';

    if (id.isNotEmpty) {
      Provider.of<ShelfProvider>(context, listen: false).addToHistory({
        '_id': id,
        'title': title,
        'videoUrl': url,
        'thumbnailUrl': thumbnailUrl,
      });
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerPage(
          videoId: id,
          videoUrl: url,
          title: title,
          thumbnailUrl: thumbnailUrl,
          showControls: true,
        ),
      ),
    );
  }

  void _openSeriesEpisodesBottomSheet(BuildContext context, dynamic seriesItem) {
    // Reverted to original chaishots logic matching prompt instructions
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeriesScreen(initialSeriesId: seriesItem['id']?.toString() ?? seriesItem['_id']?.toString() ?? ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // 🔍 SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Vethikithe dorakanidi edi leduuu..",
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 RESULTS
            Expanded(
              child: _isSearching ? _buildSearchResults() : _buildHomeView(),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 SEARCH RESULTS VIEW
  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, color: Colors.grey, size: 60),
            SizedBox(height: 16),
            Text(
              "Not found!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Neeku kavalsindhi na daggara ledu!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 120 / 200, // Adjusted for 120x160 + text
      ),
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        final String imgUrl = item['thumbnailUrl'] ?? '';
        final String title = item['title'] ?? 'No Title';

        return GestureDetector(
          onTap: () {
            if (item['type'] == 'series') {
              _openSeriesEpisodesBottomSheet(context, item);
            } else {
              _playVideo(item);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPoster(imgUrl),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔥 HOME VIEW (WHEN NOT SEARCHING)
  Widget _buildHomeView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Popular Searches"),
          _buildPopularSearches(),
          const SizedBox(height: 24),

          _buildSectionTitle("Popular Genres"),
          _buildPopularGenres(),
          const SizedBox(height: 24),

          _buildSectionTitle("Recommendations for you"),
          _buildRecommendations(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // 🏷️ SECTION TITLE
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 🎬 POPULAR SEARCHES
  Widget _buildPopularSearches() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _popularSearches.length,
        itemBuilder: (context, index) {
          final item = _popularSearches[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                _searchController.text = item['title']!;
                _performSearch(item['title']!);
              },
              child: _buildPoster(item['image']!),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularGenres() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _popularGenres.length,
        itemBuilder: (context, index) {
          final genre = _popularGenres[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                _searchController.text = genre['name']!;
                _performSearch(genre['name']!);
              },
              child: Container(
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      genre['image']!.startsWith('assets/')
                          ? Image.asset(
                              genre['image']!,
                              width: 250,
                              height: 120,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              genre['image']!,
                              width: 250,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: Colors.grey[800]),
                            ),
                      Container(color: Colors.black.withOpacity(0.4)),
                      Center(
                        child: Text(
                          genre['name']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 🤖 RECOMMENDATIONS
  Widget _buildRecommendations() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _recommendationImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _playVideo({'title': 'Recommendation ${index + 1}', 'thumbnailUrl': _recommendationImages[index]}),
              child: Container(
                width: 140,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.yellow, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    _recommendationImages[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 🖼️ REUSABLE POSTER WIDGET
  Widget _buildPoster(
    String imageUrl, {
    double width = 120,
    double height = 160,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.broken_image, color: Colors.grey, size: 30),
                  SizedBox(height: 4),
                  Text(
                    "IMG Error",
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// 🔥 API SERVICE
class SearchService {
  static String get baseUrl => ApiConstants.baseUrl;

  static Future<List<dynamic>> searchVideos(String query) async {
    try {
      final String url = '$baseUrl/search?query=$query';
      print("FETCHING: $url");
// ... rest of the code ...

      final response = await http.get(Uri.parse(url));

      // 👉 EXACT DEBUG REQUIREMENT
      print(response.body);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);

        if (data is Map && data.containsKey('results')) {
          return data['results'];
        }
        return [];
      } else {
        print("HTTP ERROR: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("SERVICE ERROR: $e");
      return [];
    }
  }

  static Future<List<dynamic>> getEpisodesForSeries(String seriesId) async {
    try {
      final String url = '$baseUrl/episodes/$seriesId';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
