import 'dart:convert';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/content_model.dart';
import '../widgets/share_sheet.dart';
import '../widgets/clap_bottom_sheet.dart';
import '../providers/shelf_provider.dart';
import 'premium_screen.dart';
import '../services/local_history_service.dart';

class SeriesScreen extends StatefulWidget {
  final String? initialSeriesId;
  const SeriesScreen({super.key, this.initialSeriesId});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  List<ContentModel> contentList = [];
  bool _isLoading = true;
  int _currentPageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    List<String> videoPaths = [];
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      videoPaths = manifestMap.keys
          .where((String key) => key.endsWith('.mp4'))
          .where((String key) => key.contains('assets/videos/') || key.contains('search_series_episodes/'))
          .toList();
    } catch (e) {
      debugPrint("Could not read AssetManifest.json, using fallback: $e");
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
        contentList = videoPaths.asMap().entries.map((entry) {
          int idx = entry.key + 1;
          String path = entry.value;
          return ContentModel(
            id: "ep$idx",
            title: "Episode $idx",
            rating: "U/A 16+",
            genre: "Drama",
            type: "Short",
            description: "Chai Shots episode $idx playing locally.",
            assetPath: path,
            thumbnail: "https://picsum.photos/300/300?random=$idx",
            bgColor: const Color(0xFF5B4A3F),
          );
        }).toList();
        _isLoading = false;
      });
    }
  }

  void _jumpToEpisode(int index) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFFD700))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
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
          return VideoCardSeries(
            content: contentList[index],
            currentPageIndex: _currentPageIndex,
            contentList: contentList,
            myIndex: index,
            onEpisodeTap: _jumpToEpisode,
          );
        },
      ),
    );
  }
}

// ----------------------------------------------------
// VideoCard for Series Screen (Original Logic + New Updates)
// ----------------------------------------------------
class VideoCardSeries extends StatefulWidget {
  final ContentModel content;
  final int currentPageIndex;
  final List<ContentModel> contentList;
  final int myIndex;
  final Function(int) onEpisodeTap;

  const VideoCardSeries({
    super.key,
    required this.content,
    required this.currentPageIndex,
    required this.contentList,
    required this.myIndex,
    required this.onEpisodeTap,
  });

  @override
  State<VideoCardSeries> createState() => _VideoCardSeriesState();
}

class _VideoCardSeriesState extends State<VideoCardSeries> {
  late VideoPlayerController _controller;
  bool _isMuted = false;
  bool _isExpanded = false;
  bool _hasSubtitles = false;
  String _selectedQuality = "Auto";
  final List<Map<String, dynamic>> _castList = [
    {'name': 'Praveen Ram',     'role': 'Actor',    'claps': 0, 'color': 0xFF3A6B8A, 'imageUrl': 'https://picsum.photos/seed/praveen/150/150'},
    {'name': 'Kiriti Damaraju', 'role': 'Actor',    'claps': 0, 'color': 0xFF6B4C8A, 'imageUrl': 'https://picsum.photos/seed/kiriti/150/150'},
    {'name': 'K Sudha',         'role': 'Actor',    'claps': 0, 'color': 0xFF8A3A3A, 'imageUrl': 'https://picsum.photos/seed/sudha/150/150'},
  ];
  final List<Map<String, dynamic>> _crewList = [
    {'name': 'Dharma Teja', 'role': 'Writer',   'claps': 0, 'color': 0xFF2E6B3A, 'imageUrl': 'https://picsum.photos/seed/dharma/150/150'},
    {'name': 'Chaitanya P', 'role': 'Director', 'claps': 0, 'color': 0xFF1A4A7A, 'imageUrl': 'https://picsum.photos/seed/chaitanya/150/150'},
  ];

  @override
  void initState() {
    super.initState();
    // FORCE LOCAL ASSET CONTROLLER
    _controller = VideoPlayerController.asset(widget.content.assetPath);
    
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() { _isMuted = false; });
      if (widget.myIndex == 0) {
        _trackHistory();
        _controller.setVolume(1.0);
        _controller.setLooping(true);
        _controller.play();
        WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) setState(() {}); });
      } else {
        _controller.setVolume(1.0);
        _controller.setLooping(true);
      }
    });
  }

  @override
  void didUpdateWidget(VideoCardSeries oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPageIndex != oldWidget.currentPageIndex) {
      if (widget.myIndex == widget.currentPageIndex) {
        setState(() { _isMuted = false; });
        _trackHistory();
        _controller.setVolume(1.0);
        _controller.setLooping(true);
        _controller.play();
      } else {
        _controller.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _trackHistory() {
    Provider.of<ShelfProvider>(context, listen: false).addToHistory({
      '_id': widget.content.id.toString(),
      'title': widget.content.title,
      'videoUrl': widget.content.assetPath,
      'thumbnailUrl': widget.content.thumbnail,
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
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

  void _showVideoQualityBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Video Quality", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () { setState(() => _selectedQuality = "Auto"); Navigator.pop(ctx); },
                child: Container(width: double.infinity, height: 56,
                    decoration: BoxDecoration(
                        color: _selectedQuality == "Auto" ? Colors.transparent : const Color(0xFF2C2C2C),
                        border: _selectedQuality == "Auto" ? Border.all(color: const Color(0xFFFFD700), width: 2) : null,
                        borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text("Auto", style: TextStyle(color: _selectedQuality == "Auto" ? const Color(0xFFFFD700) : Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () { setState(() => _selectedQuality = "1080p"); Navigator.pop(ctx); },
                child: Container(width: double.infinity, height: 56,
                    decoration: BoxDecoration(
                        color: _selectedQuality == "1080p" ? Colors.transparent : const Color(0xFF2C2C2C),
                        border: _selectedQuality == "1080p" ? Border.all(color: const Color(0xFFFFD700), width: 2) : null,
                        borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text("1080p", style: TextStyle(color: _selectedQuality == "1080p" ? const Color(0xFFFFD700) : Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () { setState(() => _selectedQuality = "720p"); Navigator.pop(ctx); },
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
  }

  void _showMoreBottomSheet() {
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
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Consumer<ShelfProvider>(
                          builder: (context, shelf, child) {
                            final isSaved = shelf.isVideoSaved(widget.content.id.toString());
                            return GestureDetector(
                              onTap: () async {
                                await shelf.toggleSaved({
                                  '_id': widget.content.id.toString(),
                                  'title': widget.content.title,
                                  'videoUrl': widget.content.assetPath,
                                  'thumbnailUrl': widget.content.thumbnail,
                                });
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(!isSaved ? "Saved to Shelf!" : "Removed from Shelf!")),
                                  );
                                }
                              },
                              child: Container(height: 96,
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
                      ),
                      const SizedBox(width: 12),
                      const Expanded(child: SizedBox.shrink()), // Empty space to align the button
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showShareBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ShareSheet(video: widget.content),
    );
  }

  void _showEpisodesModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("All Episodes", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                GestureDetector(onTap: () => Navigator.pop(ctx), child: const Icon(Icons.close, color: Colors.white)),
              ]
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.contentList.length,
                itemBuilder: (context, index) {
                  final ep = widget.contentList[index];
                  final isPlaying = index == widget.myIndex;
                  return ListTile(
                    leading: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(ep.thumbnail, width: 80, height: 50, fit: BoxFit.cover)),
                        if (isPlaying) const Icon(Icons.play_circle_fill, color: Colors.yellow, size: 30),
                      ]
                    ),
                    title: Text(ep.title, style: TextStyle(color: isPlaying ? Colors.yellow : Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(ep.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    onTap: () {
                      Navigator.pop(ctx);
                      widget.onEpisodeTap(index);
                    },
                  );
                }
              )
            )
          ]
        )
      )
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
              : const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700))),
        ),

        // Dim gradient overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.4, 1.0],
                colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
              ),
            ),
          ),
        ),

        // CENTER: Play/Pause indicator
        Center(
          child: GestureDetector(
            onTap: () {
              setState(() { 
                if (_controller.value.isPlaying) {
                  _controller.pause(); 
                } else {
                  _controller.play();
                }
              });
            },
            child: AnimatedOpacity(
              opacity: _controller.value.isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.4)),
                child: const Icon(Icons.play_arrow, size: 60, color: Colors.white),
              ),
            ),
          ),
        ),

        // TOP LEFT AND RIGHT CONTROLS
        Positioned(
          top: 50, left: 16, right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(_hasSubtitles ? Icons.closed_caption : Icons.closed_caption_disabled, color: _hasSubtitles ? Colors.yellow : Colors.white),
                    onPressed: () {
                      setState(() { _hasSubtitles = !_hasSubtitles; });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_hasSubtitles ? "Subtitles Enabled" : "Subtitles Disabled")));
                    },
                  ),
                  IconButton(
                    icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
                    onPressed: () { setState(() { _isMuted = !_isMuted; _controller.setVolume(_isMuted ? 0 : 1); }); },
                  ),
                ],
              ),
            ],
          ),
        ),

        // RIGHT ACTION BAR
        Positioned(
          right: 12, bottom: 180,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSideAction(
                child: Transform.rotate(angle: -0.4, child: const Icon(Icons.send, color: Colors.white, size: 28)),
                label: "Share", onTap: _showShareBottomSheet,
              ),
              const SizedBox(height: 24),
              _buildSideAction(
                child: const Icon(Icons.video_library, color: Colors.white, size: 28),
                label: "Episodes", onTap: _showEpisodesModal,
              ),
              const SizedBox(height: 24),
              _buildSideAction(
                child: const Icon(Icons.more_vert, color: Colors.white, size: 28),
                label: "More", onTap: _showMoreBottomSheet,
              ),
            ],
          ),
        ),

        // BOTTOM LEFT INFO
        Positioned(
          left: 16, right: 80, bottom: 130,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.content.title, style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Text(widget.content.description, maxLines: _isExpanded ? 10 : 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 13)),
                    Text(_isExpanded ? "Read Less" : "Read More", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  ]
                ),
              ),
            ],
          ),
        ),

        // BOTTOM PROGRESS & PREMIUM BUTTON
        Positioned(
          left: 0, right: 0, bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildProgressBar(),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 12, spreadRadius: 1, offset: const Offset(0, 4))],
                ),
                child: ElevatedButton.icon(
                  onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const PremiumScreen())); },
                  icon: const Icon(Icons.workspace_premium, color: Colors.black, size: 20),
                  label: const Text('Go Premium', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, VideoPlayerValue value, child) {
              return Text(_formatDuration(value.position), style: const TextStyle(color: Colors.white, fontSize: 12));
            },
          ),
          Expanded(
            child: VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Colors.yellow,
                bufferedColor: Colors.white24,
                backgroundColor: Colors.white10,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
          Text(_formatDuration(_controller.value.duration), style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
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
        ]
      )
    );
  }
}
