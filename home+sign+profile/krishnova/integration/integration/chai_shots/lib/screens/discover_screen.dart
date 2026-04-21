import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'premium_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Needed for web checks
import '../models/content_model.dart';
import '../services/discover_api_service.dart';
import '../widgets/clap_bottom_sheet.dart';
import '../widgets/share_sheet.dart';
import 'subscribe_screen.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../services/shelf_api_service.dart' as ShelfApi;
import '../services/local_history_service.dart';
import '../services/local_saved_service.dart';
import 'package:share_plus/share_plus.dart';
import 'search_screen.dart';
import 'shelf_page.dart';
import 'package:provider/provider.dart';
import '../providers/shelf_provider.dart';

VideoPlayerController? globalDiscoverController;

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  List<ContentModel> contentList = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ApiService.fetchContent();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("API Success")));

      if (data.isNotEmpty) {
        setState(() {
          contentList = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Database returned empty list. No active content found.";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      print("API ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("API Failed")));
      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFFFFD700)),
              SizedBox(height: 16),
              Text("Loading content...", style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.yellow, size: 60),
              const SizedBox(height: 16),
              Text(_errorMessage!, style: const TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadContent,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
                child: const Text("Retry", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: contentList.length,
        onPageChanged: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return VideoCard(
            content: contentList[index],
            currentPageIndex: _currentPageIndex,
            contentList: contentList,
            myIndex: index,
          );
        },
      ),
    );
  }
}

class VideoCard extends StatefulWidget {
  final ContentModel content;
  final int currentPageIndex;
  final List<ContentModel> contentList;
  final int myIndex;

  const VideoCard({
    super.key,
    required this.content,
    required this.currentPageIndex,
    required this.contentList,
    required this.myIndex,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  late VideoPlayerController _controller;
  bool _isMuted = false;
  bool _isExpanded = false;
  String _selectedQuality = "Auto";

  final List<Map<String, dynamic>> _castList = [
    {'name': 'Praveen Ram',     'role': 'Actor',    'claps': 0, 'color': 0xFF3A6B8A, 'imageUrl': 'https://picsum.photos/seed/praveen/150/150'},
    {'name': 'Kiriti Damaraju', 'role': 'Actor',    'claps': 0, 'color': 0xFF6B4C8A, 'imageUrl': 'https://picsum.photos/seed/kiriti/150/150'},
    {'name': 'K Sudha',         'role': 'Actor',    'claps': 0, 'color': 0xFF8A3A3A, 'imageUrl': 'https://picsum.photos/seed/sudha/150/150'},
  ];
  final List<Map<String, dynamic>> _crewList = [
    {'name': 'Dharma Teja', 'role': 'Writer',   'claps': 0, 'color': 0xFF2E6B3A, 'imageUrl': 'https://picsum.photos/seed/dharma/150/150'},
    {'name': 'Chaitanya P', 'role': 'Director', 'claps': 0, 'color': 0xFF1A4A7A, 'imageUrl': 'https://picsum.photos/seed/chaitanya/150/150'},
    {'name': 'Aadi Raju',   'role': 'DOP',      'claps': 0, 'color': 0xFF5A5A2A, 'imageUrl': 'https://picsum.photos/seed/aadi/150/150'},
  ];

  @override
  void initState() {
    super.initState();
    debugPrint("🎬 [Video Card] Initializing video: ${widget.content.title}");
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final String videoUrl = widget.content.assetPath;
    
    if (videoUrl.startsWith('http')) {
      _controller = VideoPlayerController.network(videoUrl);
    } else {
      _controller = VideoPlayerController.asset(videoUrl);
    }
    
    try {
      await _controller.initialize();
      if (!mounted) return;
      
      debugPrint("✅ [Video Card] Initialized successfully: ${widget.content.title}");
      
      setState(() {});
      
      if (widget.myIndex == widget.currentPageIndex) {
        globalDiscoverController = _controller;
        _controller.setVolume(1.0);
        _controller.setLooping(true);
        await _controller.play();
        setState(() {
          _isMuted = false;
        });
      } else {
        _controller.setVolume(0.0);
        _controller.setLooping(true);
        setState(() {
          _isMuted = true;
        });
      }
    } catch (e) {
      debugPrint("❌ [Video Card] Initialization failed for $videoUrl: $e");
    }
  }

  @override
  void didUpdateWidget(VideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPageIndex != oldWidget.currentPageIndex) {
      if (widget.myIndex == widget.currentPageIndex) {
        globalDiscoverController = _controller;
        setState(() {
          _isMuted = false;
        });
        _controller.setVolume(1.0);
        _controller.setLooping(true);
        _controller.play().catchError((e) {
          debugPrint("❌ [Video Card] Play error after scroll: $e");
        });
      } else {
        _controller.pause();
      }
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }


  void _showInfoBottomSheet(BuildContext context, ContentModel content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Show Details",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    content.thumbnail,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      width: 110, height: 110,
                      color: content.bgColor,
                      child: Center(child: Text(content.title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white54),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(content.rating,
                            style: const TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                      const SizedBox(height: 8),
                      Text(content.title,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text("Episode 0 / 24",
                          style: TextStyle(color: Colors.white60, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text("Synopsis",
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(content.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () { Navigator.pop(ctx); _showFullInfoBottomSheet(context, content); },
              child: const Text("Show More",
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Consumer<ShelfProvider>(
                  builder: (context, shelf, child) {
                    final isSaved = shelf.isVideoSaved(content.id.toString());
                    return GestureDetector(
                      onTap: () async {
                        await shelf.toggleSaved({
                          '_id': content.id.toString(),
                          'title': content.title,
                          'videoUrl': content.assetPath,
                          'thumbnailUrl': content.thumbnail,
                        });
                      },
                      child: Column(children: [
                        Icon(isSaved ? Icons.favorite : Icons.favorite_border, color: isSaved ? Colors.yellow : Colors.white, size: 28),
                        const SizedBox(height: 4),
                        Text(isSaved ? "Saved" : "Save", style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ]),
                    );
                  }
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => ShareSheet(video: content),
                    );
                  },
                  child: Column(children: [
                    Transform.rotate(angle: -0.4, child: const Icon(Icons.send, color: Colors.white, size: 28)),
                    const SizedBox(height: 4),
                    const Text("Share", style: TextStyle(color: Colors.white, fontSize: 12)),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _showFullInfoBottomSheet(BuildContext context, ContentModel content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
              color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Show Details",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                GestureDetector(onTap: () => Navigator.pop(ctx),
                    child: const Icon(Icons.close, color: Colors.white, size: 22)),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Synopsis",
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(content.description,
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Consumer<ShelfProvider>(
                  builder: (context, shelf, child) {
                    final isSaved = shelf.isVideoSaved(content.id.toString());
                    return GestureDetector(
                      onTap: () async {
                        await shelf.toggleSaved({
                          '_id': content.id.toString(),
                          'title': content.title,
                          'videoUrl': content.assetPath,
                          'thumbnailUrl': content.thumbnail,
                        });
                      },
                      child: Column(children: [
                        Icon(isSaved ? Icons.favorite : Icons.favorite_border, color: isSaved ? Colors.yellow : Colors.white, size: 28),
                        const SizedBox(height: 4),
                        Text(isSaved ? "Saved" : "Save", style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ]),
                    );
                  }
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => ShareSheet(video: content),
                    );
                  },
                  child: Column(children: [
                    Transform.rotate(angle: -0.4, child: const Icon(Icons.send, color: Colors.white, size: 28)),
                    const SizedBox(height: 4),
                    const Text("Share", style: TextStyle(color: Colors.white, fontSize: 12)),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _showVideoQualityBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Quality",
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      GestureDetector(onTap: () => Navigator.pop(ctx),
                          child: const Icon(Icons.close, color: Colors.white, size: 24)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: GestureDetector(
                        onTap: () { setModalState(() => _selectedQuality = "480p"); setState(() => _selectedQuality = "480p"); },
                        child: Container(height: 56,
                            decoration: BoxDecoration(
                                color: _selectedQuality == "480p" ? Colors.transparent : const Color(0xFF2C2C2C),
                                border: _selectedQuality == "480p" ? Border.all(color: const Color(0xFFFFD700), width: 2) : null,
                                borderRadius: BorderRadius.circular(12)),
                            child: Center(child: Text("480p", style: TextStyle(color: _selectedQuality == "480p" ? const Color(0xFFFFD700) : Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: GestureDetector(
                        onTap: () { setModalState(() => _selectedQuality = "Auto"); setState(() => _selectedQuality = "Auto"); },
                        child: Container(height: 56,
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(color: _selectedQuality == "Auto" ? const Color(0xFFFFD700) : Colors.transparent, width: 2),
                                borderRadius: BorderRadius.circular(12)),
                            child: Center(child: Text("Auto", style: TextStyle(color: _selectedQuality == "Auto" ? const Color(0xFFFFD700) : Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))),
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () { setModalState(() => _selectedQuality = "1080p"); setState(() => _selectedQuality = "1080p"); },
                    child: Container(width: double.infinity, height: 56,
                        decoration: BoxDecoration(
                            color: _selectedQuality == "1080p" ? Colors.transparent : const Color(0xFF2C2C2C),
                            border: _selectedQuality == "1080p" ? Border.all(color: const Color(0xFFFFD700), width: 2) : null,
                            borderRadius: BorderRadius.circular(12)),
                        child: Center(child: Text("1080p", style: TextStyle(color: _selectedQuality == "1080p" ? const Color(0xFFFFD700) : Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () { setModalState(() => _selectedQuality = "720p"); setState(() => _selectedQuality = "720p"); },
                    child: Container(width: double.infinity, height: 56,
                        decoration: BoxDecoration(
                            color: _selectedQuality == "720p" ? Colors.transparent : const Color(0xFF2C2C2C),
                            border: _selectedQuality == "720p" ? Border.all(color: const Color(0xFFFFD700), width: 2) : null,
                            borderRadius: BorderRadius.circular(12)),
                        child: Center(child: Text("720p", style: TextStyle(color: _selectedQuality == "720p" ? const Color(0xFFFFD700) : Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ADDED MISSING MORE SHEET
  void _showMoreBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.black54, // Semi-transparent black for glass effect
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("More",
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      GestureDetector(onTap: () => Navigator.pop(ctx),
                          child: const Icon(Icons.close, color: Colors.white, size: 24)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: GestureDetector(
                        onTap: () { Navigator.pop(ctx); _showInfoBottomSheet(context, widget.contentList[widget.currentPageIndex]); },
                        child: Container(height: 96,
                          decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(16)),
                          child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.info_outline, color: Colors.white, size: 28),
                            SizedBox(height: 8),
                            Text("Show Info", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: GestureDetector(
                        onTap: () { Navigator.pop(ctx); _showVideoQualityBottomSheet(context); },
                        child: Container(height: 96,
                          decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(16)),
                          child: Stack(children: [
                            const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.settings, color: Colors.white, size: 28),
                              SizedBox(height: 8),
                              Text("Video Quality", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                            ])),
                            Positioned(
                              bottom: 12, right: 12,
                              child: Text(_selectedQuality, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.bold))
                            )
                          ]),
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: GestureDetector(
                        onTap: () { 
                          Navigator.pop(ctx); 
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (ctx) => ClapBottomSheet(castList: _castList, crewList: _crewList),
                          );
                        },
                        child: Container(height: 96,
                          decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(16)),
                          child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.front_hand_outlined, color: Colors.white, size: 28),
                            SizedBox(height: 8),
                            Text("Send Clap", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      )),
                      const SizedBox(width: 12),
                      Expanded(
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: 0.4,
                            child: Container(
                              height: 96,
                              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(16)),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Container(
                                  decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1.5), borderRadius: BorderRadius.circular(4)),
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  child: const Text("CC", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(height: 8),
                                const Text("Subtitle Settings", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Consumer<ShelfProvider>(
                    builder: (context, shelf, child) {
                      final isSaved = shelf.isVideoSaved(widget.contentList[widget.currentPageIndex].id.toString());
                      return GestureDetector(
                        onTap: () async {
                          await shelf.toggleSaved({
                            '_id': widget.contentList[widget.currentPageIndex].id.toString(),
                            'title': widget.contentList[widget.currentPageIndex].title,
                            'videoUrl': widget.contentList[widget.currentPageIndex].assetPath,
                            'thumbnailUrl': widget.contentList[widget.currentPageIndex].thumbnail,
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(!isSaved ? "Saved to Shelf!" : "Removed from Shelf!")),
                            );
                          }
                        },
                        child: Container(
                          width: double.infinity, height: 96,
                          decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(16)),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(isSaved ? Icons.favorite : Icons.favorite_border, color: Colors.white, size: 28),
                            const SizedBox(height: 8),
                            Text(isSaved ? "Saved" : "Save",
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      );
                    }
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ADDED MISSING SHARE SHEET + ACTUAL SHARE FUNCTIONALITY
  void _showShareBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ShareSheet(video: widget.content),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('video-card-${widget.content.id}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.5) {
          if (!_controller.value.isPlaying) {
            _controller.play().catchError((e) {
              debugPrint("❌ [Visibility] Play error: $e");
            });
          }
        } else {
          if (_controller.value.isPlaying) {
            _controller.pause();
          }
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
        _controller.value.isInitialized
            ? FittedBox(fit: BoxFit.cover,
            child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller)))
            : const SizedBox(),
        Positioned.fill(
            child: DecoratedBox(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.5, 1.0],
                        colors: [Colors.transparent, Colors.black.withOpacity(0.9)])))),
        Positioned(
          top: 50, left: 16,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        Positioned(
          top: 50, right: 16,
          child: IconButton(
            icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
            onPressed: () {
              setState(() { _isMuted = !_isMuted; _controller.setVolume(_isMuted ? 0 : 1); });
            },
          ),
        ),
        Center(child: GestureDetector(
          onTap: () {
            setState(() { 
              if (_controller.value.isPlaying) {
                _controller.pause(); 
              } else {
                _controller.play().catchError((e) {
                  debugPrint("❌ [Video Card] Tap play error: $e");
                });
              }
            });
          },
          child: AnimatedOpacity(
              opacity: _controller.value.isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(width: 80, height: 80,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.4)),
                  child: const Icon(Icons.play_arrow, size: 60, color: Colors.white))),
        )),
        Positioned(
          right: 12, bottom: 100,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _buildSideAction(
              child: Container(padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1.5), borderRadius: BorderRadius.circular(4)),
                  child: const Text("CC", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
              label: "Subtitles",
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Subtitles not available"))),
            ),
            const SizedBox(height: 24),
            _buildSideAction(
              child: Transform.rotate(angle: -0.4, child: const Icon(Icons.send, color: Colors.white, size: 28)),
              label: "Share",
              onTap: () => _showShareBottomSheet(context),
            ),
            const SizedBox(height: 24),
            _buildSideAction(
              child: const Text("• • •", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              label: "More",
              onTap: () => _showMoreBottomSheet(context),
            ),
          ]),
        ),
        Positioned(
          left: 16, right: 80, bottom: 100, // Changed right to 80 to not overlap side action bar
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.content.title,
                style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 28, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            Row(children: [
              GestureDetector(onTap: () { _controller.pause(); Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen())); }, child: _buildChip(widget.content.rating)),
              GestureDetector(onTap: () { _controller.pause(); Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen())); }, child: _buildChip(widget.content.genre)),
              GestureDetector(onTap: () { _controller.pause(); Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen())); }, child: _buildChip(widget.content.type)),
            ]),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.content.description,
                    maxLines: _isExpanded ? 10 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
                Text(_isExpanded ? "Read Less" : "Read More",
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              ]),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, // Automatically fill available space (left 16 -> right 80)
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                onPressed: () {
                  _controller.pause(); // Pause video when navigating
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
                },
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 26, height: 26,
                    decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                    child: const Icon(Icons.workspace_premium, color: Color(0xFFFFD700), size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text("Subscribe Now", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
          ]),
        ),
      ],
      ),
    );
  }

  Widget _buildSideAction({required Widget child, required String label, required VoidCallback onTap}) {
    return GestureDetector(onTap: onTap,
        child: Column(children: [
          child,
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11))
        ]));
  }

  Widget _buildChip(String label) {
    if (label.isEmpty) return const SizedBox();
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}
