import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/content_model.dart';
import '../services/local_video_mapper.dart';
import '../services/local_history_service.dart';
import '../services/shelf_api_service.dart' as ShelfApi;
import '../services/local_saved_service.dart';
import '../widgets/share_sheet.dart';
import '../widgets/clap_bottom_sheet.dart';
import '../providers/shelf_provider.dart';
import 'package:provider/provider.dart';
import 'premium_screen.dart';

const _kYellow = Color(0xFFFFD000);

class VideoPlayerPage extends StatefulWidget {
  final String videoId;
  final String videoUrl;
  final String title;
  final String? thumbnailUrl;
  final bool showControls;

  const VideoPlayerPage({
    super.key,
    required this.videoId,
    required this.videoUrl,
    required this.title,
    this.thumbnailUrl,
    this.showControls = false,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  List<ContentModel> contentList = [];
  bool _isLoading = true;
  int _currentPageIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _loadContent();
  }

  Future<void> _loadContent() async {
    List<String> videoPaths = [];
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = jsonDecode(manifestContent);
      videoPaths = manifestMap.keys
          .where((String key) => key.endsWith('.mp4'))
          .where((String key) => key.contains('assets/videos/') || key.contains('search_series_episodes/'))
          .toList();
    } catch (e) {
      debugPrint("Asset load error: $e");
    }

    if (videoPaths.isEmpty) {
      videoPaths = [
        "assets/videos/video1.mp4",
        "assets/videos/video2.mp4",
        "assets/videos/video3.mp4",
        "assets/videos/video4.mp4",
        "assets/videos/video5.mp4",
      ];
    }

    if (mounted) {
      setState(() {
        final forcedAsset = LocalVideoMapper.forceLocalAsset(widget.videoUrl, widget.videoId);

        contentList = videoPaths.asMap().entries.map((entry) {
          int idx = entry.key + 1;
          String path = entry.value;
          bool isMatch = path == forcedAsset || path == widget.videoUrl;
          
          return ContentModel(
            id: isMatch && widget.videoId.isNotEmpty ? widget.videoId : "ep$idx",
            title: isMatch && widget.title != 'Title' ? widget.title : "Episode $idx",
            rating: "U/A 16+",
            genre: "Drama",
            type: "Short",
            description: "Chai Shots original video player episode.",
            assetPath: path,
            thumbnail: isMatch && widget.thumbnailUrl != null && widget.thumbnailUrl!.isNotEmpty 
                ? widget.thumbnailUrl! 
                : "https://picsum.photos/300/300?random=$idx",
            bgColor: const Color(0xFF5B4A3F),
          );
        }).toList();

        // Check if passed videoUrl matches any
        int initialIndex = 0;
        for (int i = 0; i < contentList.length; i++) {
          if (contentList[i].assetPath == forcedAsset || contentList[i].assetPath == widget.videoUrl) {
            initialIndex = i;
            break;
          }
        }
        
        _currentPageIndex = initialIndex;
        _pageController = PageController(initialPage: initialIndex);
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    if (!_isLoading) _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: _kYellow)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: contentList.length,
        onPageChanged: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return VideoCardScrolling(
            content: contentList[index],
            currentPageIndex: _currentPageIndex,
            myIndex: index,
            onBack: () => Navigator.pop(context),
            showControls: widget.showControls,
          );
        },
      ),
    );
  }
}

class VideoCardScrolling extends StatefulWidget {
  final ContentModel content;
  final int currentPageIndex;
  final int myIndex;
  final VoidCallback onBack;
  final bool showControls;

  const VideoCardScrolling({
    super.key,
    required this.content,
    required this.currentPageIndex,
    required this.myIndex,
    required this.onBack,
    this.showControls = false,
  });

  @override
  State<VideoCardScrolling> createState() => _VideoCardScrollingState();
}

class _VideoCardScrollingState extends State<VideoCardScrolling> {
  late VideoPlayerController _controller;
  bool _isMuted = false;
  bool _hasSubtitles = false;
  bool _showPlayPauseIcon = true;
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
    if (widget.content.assetPath.startsWith('http')) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.content.assetPath));
    } else {
      _controller = VideoPlayerController.asset(widget.content.assetPath);
    }
    
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      if (widget.myIndex == widget.currentPageIndex) {
        Provider.of<ShelfProvider>(context, listen: false).addToHistory({
          '_id': widget.content.id.toString(),
          'title': widget.content.title,
          'videoUrl': widget.content.assetPath,
          'thumbnailUrl': widget.content.thumbnail,
        });
        _controller.setLooping(true);
        _controller.play();
        _hidePlayPauseIconDelay();
      } else {
        _controller.setLooping(true);
      }
    });
  }

  @override
  void didUpdateWidget(VideoCardScrolling oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPageIndex != oldWidget.currentPageIndex) {
      if (widget.myIndex == widget.currentPageIndex) {
        Provider.of<ShelfProvider>(context, listen: false).addToHistory({
          '_id': widget.content.id.toString(),
          'title': widget.content.title,
          'videoUrl': widget.content.assetPath,
          'thumbnailUrl': widget.content.thumbnail,
        });
        _controller.play();
        _hidePlayPauseIconDelay();
      } else {
        _controller.pause();
      }
    }
  }

  void _hidePlayPauseIconDelay() {
    setState(() => _showPlayPauseIcon = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _controller.value.isPlaying) {
        setState(() => _showPlayPauseIcon = false);
      }
    });
  }

  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _showPlayPauseIcon = true;
      } else {
        _controller.play();
        _hidePlayPauseIconDelay();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showShareBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ShareSheet(video: widget.content),
    );
  }

  void _showInfoBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
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
                const Text("Show Details", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                GestureDetector(onTap: () => Navigator.pop(ctx), child: const Icon(Icons.close, color: Colors.white, size: 22)),
              ],
            ),
            const SizedBox(height: 20),
            Text(widget.content.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.content.description, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    );
  }

  void _showEpisodesModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Episodes", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  GestureDetector(onTap: () => Navigator.pop(ctx), child: const Icon(Icons.close, color: Colors.white, size: 24)),
                ]
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: ShelfApi.ApiService.getEpisodes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.yellow));
                  }
                  
                  final episodes = snapshot.data ?? [];
                  // Fallback length 20 if empty payload
                  final int episodeCount = episodes.isNotEmpty ? episodes.length : 20;

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: episodeCount,
                    itemBuilder: (context, index) {
                      bool isUnlocked = index < 3;
                      bool isCurrent = widget.myIndex == index;

                      return GestureDetector(
                        onTap: () {
                          if (isUnlocked) {
                            Navigator.pop(ctx);
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A2E), // Dark Navy Blue
                            borderRadius: BorderRadius.circular(10),
                            border: isCurrent ? Border.all(color: Colors.yellow, width: 2) : null,
                          ),
                          child: Center(
                            child: isUnlocked 
                              ? Text("${index + 1}", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))
                              : const Icon(Icons.lock, color: Colors.yellow, size: 28),
                          ),
                        ),
                      );
                    },
                  );
                }
              ),
            )
          ]
        )
      )
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
              child: Consumer<ShelfProvider>(
                builder: (context, shelf, child) {
                  final currentContent = widget.content;
                  final isSaved = shelf.isVideoSaved(currentContent.id.toString());
                  
                  return Column(
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
                            onTap: () { Navigator.pop(ctx); _showInfoBottomSheet(); },
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
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          await shelf.toggleSaved({
                            '_id': currentContent.id.toString(),
                            'title': currentContent.title,
                            'videoUrl': currentContent.assetPath,
                            'thumbnailUrl': currentContent.thumbnail,
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(!isSaved ? "Saved to Shelf!" : "Removed from Shelf!")),
                            );
                          }
                        },
                        child: Container(
                          width: double.infinity, 
                          height: 96,
                          decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(16)),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(isSaved ? Icons.favorite : Icons.favorite_border, color: Colors.white, size: 28),
                            const SizedBox(height: 8),
                            Text(isSaved ? "Saved" : "Save",
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      ),
                    ],
                  );
                }
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. VIDEO FULL SCREEN WITH BOXFIT.COVER
        Positioned.fill(
          child: _controller.value.isInitialized
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                )
              : const Center(child: CircularProgressIndicator(color: _kYellow)),
        ),

        // Dim gradient overlay (also handles full screen tap for play/pause)
        Positioned.fill(
          child: GestureDetector(
            onTap: _togglePlay,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.5, 1.0],
                  colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                ),
              ),
            ),
          ),
        ),

        // PLAY/PAUSE CENTER TAP VISIBLE FEEDBACK + SEEK BUTTONS
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.showControls)
                IconButton(
                  icon: const Icon(Icons.replay_10, size: 40, color: Colors.white),
                  onPressed: () {
                    final currentPos = _controller.value.position;
                    _controller.seekTo(currentPos - const Duration(seconds: 10));
                  },
                ),
              if (widget.showControls) const SizedBox(width: 40),
              GestureDetector(
                onTap: _togglePlay,
                child: AnimatedOpacity(
                  opacity: _showPlayPauseIcon ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.6)),
                    child: Icon(
                      _controller.value.isPlaying ? Icons.pause : Icons.play_arrow, 
                      size: 50, 
                      color: Colors.white
                    ),
                  ),
                ),
              ),
              if (widget.showControls) const SizedBox(width: 40),
              if (widget.showControls)
                IconButton(
                  icon: const Icon(Icons.forward_10, size: 40, color: Colors.white),
                  onPressed: () {
                    final currentPos = _controller.value.position;
                    _controller.seekTo(currentPos + const Duration(seconds: 10));
                  },
                ),
            ],
          ),
        ),

        // PROGRESS BAR (Conditionally shown)
        if (widget.showControls)
          Positioned(
            left: 0, right: 0, bottom: 80,
            child: VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Colors.yellow,
                bufferedColor: Colors.white24,
                backgroundColor: Colors.white10,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),

        // TOP ACTIONS
        Positioned(
          top: 50, left: 16, right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: widget.onBack,
              ),
              IconButton(
                icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
                onPressed: () { 
                  setState(() { 
                    _isMuted = !_isMuted; 
                    _controller.setVolume(_isMuted ? 0 : 1); 
                  }); 
                },
              ),
            ],
          ),
        ),

        // RIGHT SIDE ACTIONS
        Positioned(
          right: 12, bottom: 90,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSideAction(
                child: Icon(_hasSubtitles ? Icons.closed_caption : Icons.closed_caption_disabled, color: _hasSubtitles ? _kYellow : Colors.white, size: 28),
                label: "Subtitles", 
                onTap: () {
                  setState(() { _hasSubtitles = !_hasSubtitles; });
                },
              ),
              const SizedBox(height: 24),
              _buildSideAction(
                child: Transform.rotate(angle: -0.4, child: const Icon(Icons.send, color: Colors.white, size: 28)),
                label: "Share", 
                onTap: _showShareBottomSheet,
              ),
              const SizedBox(height: 24),
              _buildSideAction(
                child: const Icon(Icons.video_library, color: Colors.white, size: 28),
                label: "Episodes", 
                onTap: _showEpisodesModal,
              ),
              const SizedBox(height: 24),
              _buildSideAction(
                child: const Icon(Icons.more_vert, color: Colors.white, size: 28),
                label: "More", 
                onTap: () => _showMoreBottomSheet(context),
              ),
            ],
          ),
        ),

        // BOTTOM LEFT INFO
        Positioned(
          left: 16, right: 80, bottom: 90,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.content.title, style: GoogleFonts.poppins(color: _kYellow, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildChip("U/A 16+"),
                  _buildChip("Drama"),
                  _buildChip("Short"),
                ],
              ),
            ],
          ),
        ),

        // GO PREMIUM BUTTON AT BOTTOM (No progress bar)
        Positioned(
          left: 0, right: 0, bottom: 20,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 12, spreadRadius: 1, offset: const Offset(0, 4))],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () { 
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PremiumScreen())); 
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD000), // _kYellow
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 26, height: 26,
                          decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                          child: const Icon(Icons.workspace_premium, color: Color(0xFFFFD000), size: 18),
                        ),
                        const SizedBox(width: 8),
                        const Text('Go Premium', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSideAction({required Widget child, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap, 
      child: Column(
        children: [
          child, 
          const SizedBox(height: 4), 
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11))
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    if (label.isEmpty) return const SizedBox();
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12))
    );
  }
}