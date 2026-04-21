import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/shelf_provider.dart';
import '../services/shelf_api_service.dart';
import 'shelf_subscription_page.dart';
import 'shelf_video_player_page.dart';

const Color kYellow = Color(0xFFFFD000);

class ShelfPage extends StatefulWidget {
  const ShelfPage({super.key});

  @override
  State<ShelfPage> createState() => _ShelfPageState();
}

class _ShelfPageState extends State<ShelfPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _editMode = false;
  final Set<int> _selectedItems = {};
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _editMode = false;
          _selectedItems.clear();
          _selectAll = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Provider replaces manual load methods.

  // ── Get episode data from saved/history item ──────────────────────────────
  // Batch backend: { episodeId: { _id, title, videoUrl, thumbnail, ... } }
  Map<String, dynamic> _getEpisode(dynamic item) {
    if (item is Map) {
      final ep = item['contentId'] ?? item['episodeId'];
      if (ep is Map) return Map<String, dynamic>.from(ep);
      return Map<String, dynamic>.from(item);
    }
    return {};
  }

  // ── Get episode ID for delete ─────────────────────────────────────────────
  String _getEpisodeId(dynamic item) {
    if (item is Map) {
      final ep = item['contentId'] ?? item['videoId'] ?? item['episodeId'] ?? item['id'] ?? item['_id'];
      if (ep is Map) return ep['_id']?.toString() ?? ep['id']?.toString() ?? '';
      if (ep is String) return ep;
      if (ep is int) return ep.toString();
    }
    return '';
  }

  // ── Get thumbnail URL ─────────────────────────────────────────────────────
  String? _getThumbnail(Map<String, dynamic> episode) {
    final thumb = episode['thumbnail'] ?? episode['thumbnailUrl'];
    if (thumb == null) return null;
    // Check if it's a real URL
    if (thumb.toString().startsWith('http')) return thumb.toString();
    // Local asset path → return null (use fallback)
    return null;
  }

  // ── Get video URL ─────────────────────────────────────────────────────────
  String _getVideoUrl(Map<String, dynamic> episode) {
    return episode['videoUrl'] ?? episode['url'] ?? '';
  }

  // ── Open video player ─────────────────────────────────────────────────────
  void _openVideo(Map<String, dynamic> episode) {
    final videoUrl = _getVideoUrl(episode);
    final title = episode['title'] ?? episode['name'] ?? 'Unknown';
    final thumbnail = _getThumbnail(episode);
    final videoId = episode['_id']?.toString() ??
        episode['id']?.toString() ??
        episode['contentId']?.toString() ??
        episode['videoId']?.toString() ??
        episode['episodeId']?.toString() ??
        '';

    if (videoUrl.isEmpty) {
      _showSnack('Video URL ledu!');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerPage(
          videoId: videoId,
          videoUrl: videoUrl,
          title: title,
          thumbnailUrl: thumbnail,
        ),
      ),
    );
  }

  SliverGridDelegateWithFixedCrossAxisCount _gridDelegate(
      BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns =
        width > 900 ? 6 : width > 700 ? 5 : width > 500 ? 4 : 3;
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 0.62,
    );
  }

  void _toggleEdit() => setState(() {
        _editMode = !_editMode;
        _selectedItems.clear();
        _selectAll = false;
      });

  void _toggleSelectAll(int savedCount) {
    setState(() {
      _selectAll = !_selectAll;
      _selectAll
          ? _selectedItems.addAll(List.generate(savedCount, (i) => i))
          : _selectedItems.clear();
    });
  }

  Future<void> _deleteSelected(List<dynamic> savedVideos) async {
    final episodeIds =
        _selectedItems.map((i) => _getEpisodeId(savedVideos[i])).toList();
    final success = await ApiService.removeMultipleSaved(episodeIds);
    if (success) {
      for (final id in episodeIds) {
         await Provider.of<ShelfProvider>(context, listen: false).toggleSaved({'_id': id});
      }
      setState(() {
        _selectedItems.clear();
        _selectAll = false;
        _editMode = false;
      });
      _showSnack('Deleted ${episodeIds.length} item(s) ✅');
    } else {
      _showSnack('Delete failed. Try again!');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.grey[900]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSaved = _tabController.index == 0;
    final showDeleteBar = _editMode && isSaved && _selectedItems.isNotEmpty;

    final savedVideos = context.watch<ShelfProvider>().saved;
    final historyVideos = context.watch<ShelfProvider>().history;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTabBar(),
            const Divider(height: 0.5, color: Colors.white12),
            if (_editMode && isSaved) _buildSelectAllRow(savedVideos.length),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSavedTab(showDeleteBar, savedVideos),
                  _buildHistoryTab(historyVideos),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: showDeleteBar
          ? SafeArea(
              child: Container(
                color: Colors.black,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => _deleteSelected(savedVideos),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kYellow,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Delete (${_selectedItems.length})',
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/chai_logo.png',
            height: 52,
            errorBuilder: (_, __, ___) => const Text(
              'CHAI\nSHOTS',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  height: 1.1),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SubscriptionPage()),
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: kYellow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(children: [
                FaIcon(FontAwesomeIcons.crown,
                    color: Colors.black, size: 15),
                SizedBox(width: 8),
                Text('Subscribe',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab Bar ────────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: kYellow,
      indicatorWeight: 2.5,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white38,
      labelStyle:
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      unselectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
      tabs: const [Tab(text: 'Saved'), Tab(text: 'History')],
    );
  }

  // ── Select All Row ─────────────────────────────────────────────────────────
  Widget _buildSelectAllRow(int savedCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Colors.white12, width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleSelectAll(savedCount),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: _selectAll ? kYellow : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _selectAll ? kYellow : Colors.white54,
                  width: 2,
                ),
              ),
              child: _selectAll
                  ? const Icon(Icons.check_rounded,
                      color: Colors.black, size: 16)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Select all',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          GestureDetector(
            onTap: _toggleEdit,
            child: const Text('Cancel',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // ── Saved Tab ──────────────────────────────────────────────────────────────
  Widget _buildSavedTab(bool showDeleteBar, List<dynamic> savedVideos) {
    if (savedVideos.isEmpty) {
      return _emptyState(
        icon: Icons.bookmark_outline_rounded,
        title: 'Savings em levikkada!',
        subtitle: 'Repati kosam savings start cheyandi',
      );
    }
    return RefreshIndicator(
      color: kYellow,
      backgroundColor: Colors.grey[900],
      onRefresh: () async => await context.read<ShelfProvider>().refresh(),
      child: Padding(
        padding:
            EdgeInsets.fromLTRB(12, 4, 12, showDeleteBar ? 80 : 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!_editMode)
              Padding(
                padding:
                    const EdgeInsets.only(top: 8, bottom: 4, right: 4),
                child: GestureDetector(
                  onTap: _toggleEdit,
                  child: const Icon(Icons.edit_outlined,
                      color: Colors.white54, size: 22),
                ),
              ),
            Expanded(
              child: GridView.builder(
                itemCount: savedVideos.length,
                gridDelegate: _gridDelegate(context),
                itemBuilder: (ctx, i) {
                  final item = savedVideos[i];
                  final episode = _getEpisode(item);
                  final selected = _selectedItems.contains(i);

                  return _PosterCard(
                    title: episode['title'] ??
                        episode['name'] ??
                        'Episode ${i + 1}',
                    thumbnailUrl: _getThumbnail(episode),
                    editMode: _editMode,
                    selected: selected,
                    onTap: () {
                      if (_editMode) {
                        // Edit mode → select/deselect
                        setState(() {
                          selected
                              ? _selectedItems.remove(i)
                              : _selectedItems.add(i);
                          _selectAll =
                              _selectedItems.length == savedVideos.length;
                        });
                      } else {
                        // Normal tap → open video! 🎬
                        _openVideo(episode);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── History Tab ────────────────────────────────────────────────────────────
  Widget _buildHistoryTab(List<dynamic> historyVideos) {
    if (historyVideos.isEmpty) {
      return _emptyState(
        icon: Icons.history_rounded,
        title: 'History em ledu!',
        subtitle: 'Meeru chusina shows ikkade kanapadathayi',
      );
    }
    return RefreshIndicator(
      color: kYellow,
      backgroundColor: Colors.grey[900],
      onRefresh: () async => await context.read<ShelfProvider>().refresh(),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: historyVideos.length,
          gridDelegate: _gridDelegate(context),
          itemBuilder: (ctx, i) {
            final item = historyVideos[i];
            final episode = _getEpisode(item);

            return _PosterCard(
              title: episode['title'] ??
                  episode['name'] ??
                  'Episode ${i + 1}',
              thumbnailUrl: _getThumbnail(episode),
              editMode: false,
              selected: false,
              // ✅ History click → video player open!
              onTap: () => _openVideo(episode),
            );
          },
        ),
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────
  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white24, size: 64),
        const SizedBox(height: 16),
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700),
            textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text(subtitle,
            style:
                const TextStyle(color: Colors.white54, fontSize: 14),
            textAlign: TextAlign.center),
      ]),
    );
  }
}

// ─── Poster Card ──────────────────────────────────────────────────────────────
class _PosterCard extends StatelessWidget {
  final String title;
  final String? thumbnailUrl;
  final bool editMode;
  final bool selected;
  final double? progress;
  final VoidCallback onTap;

  const _PosterCard({
    required this.title,
    this.thumbnailUrl,
    required this.editMode,
    required this.selected,
    this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: selected
              ? Border.all(color: kYellow, width: 2.5)
              : Border.all(color: Colors.transparent, width: 2.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Thumbnail ───────────────────────────────────────────
              thumbnailUrl != null
                  ? Image.network(
                      thumbnailUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: Colors.grey[900],
                          child: const Center(
                            child: CircularProgressIndicator(
                                color: kYellow, strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => _fallback(),
                    )
                  : _fallback(),

              // ── Bottom gradient ─────────────────────────────────────
              Positioned(
                left: 0, right: 0, bottom: 0, height: 70,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Title ───────────────────────────────────────────────
              Positioned(
                left: 7,
                right: 7,
                bottom: progress != null ? 14 : 8,
                child: Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // ── Progress bar (history) ──────────────────────────────
              if (progress != null)
                Positioned(
                  left: 0, right: 0, bottom: 0, height: 3,
                  child: LinearProgressIndicator(
                    value: progress!.clamp(0.0, 1.0),
                    backgroundColor: Colors.white24,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(kYellow),
                  ),
                ),

              // ── Checkbox (edit mode) ────────────────────────────────
              if (editMode)
                Positioned(
                  top: 7, left: 7,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: selected ? kYellow : Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: selected ? kYellow : Colors.white70,
                          width: 1.8),
                    ),
                    child: selected
                        ? const Icon(Icons.check_rounded,
                            color: Colors.black, size: 15)
                        : null,
                  ),
                ),

              // ── Play icon overlay (non-edit mode) ───────────────────
              if (!editMode)
                Positioned(
                  top: 0, left: 0, right: 0, bottom: 0,
                  child: Center(
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white70,
                        size: 24,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallback() => Container(
        color: Colors.grey[850],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie_outlined,
                color: Colors.white24, size: 32),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                style: const TextStyle(
                    color: Colors.white38, fontSize: 10),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
}