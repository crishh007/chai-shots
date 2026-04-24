import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'screens/premium_screen.dart';
import 'language_page.dart';
import 'quiz_page.dart';
import 'language_manager.dart';
import 'quiz_profile_page.dart';
import 'screens/shelf_video_player_page.dart';

Map<String, String> _getVideoDetailsForImage(String imagePath) {
  if (imagePath.contains('series1')) return {'video': 'assets/thecult.mp4', 'title': 'THE CULT'};
  if (imagePath.contains('series2')) return {'video': 'assets/30weds21.mp4', 'title': '30 WEDS 21'};
  if (imagePath.contains('series3')) return {'video': 'assets/english.mp4', 'title': 'ENGLISH MADAM PT SIR'};
  if (imagePath.contains('series4')) return {'video': 'assets/janaejigars.mp4', 'title': 'JAANE JIGARS'};
  if (imagePath.contains('series5')) return {'video': 'assets/meow.mp4', 'title': 'MEOW'};
  return {'video': 'assets/30weds21.mp4', 'title': '30 WEDS 21'};
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _sectionTitle(String title) {
    final lm = LanguageManager.instance;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        lm.get(title),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _portraitCard({
    required BuildContext context,
    required String imagePath,
    required String badge,
    bool showRank = false,
    int rank = 0,
    bool isVideo = false,
    int index = 0,
    double scale = 1.0,
  }) {
    final double w = 140 * scale;
    final double h = 210 * scale;
    final double pillOverhang = 8.0 * scale;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              final details = _getVideoDetailsForImage(imagePath);
              return VideoPlayerPage(
                videoId: '',
                videoUrl: details['video']!,
                title: details['title']!,
                showControls: true,
              );
            },
          ),
        );
      },
      child: SizedBox(
        width: showRank ? w + 18 : w,
        height: h + pillOverhang,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            if (showRank)
              Positioned(
                left: 0,
                bottom: 0,
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.white12,
                    height: 1,
                  ),
                ),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: w,
                height: h,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: const Color(0xFF121212)),
                  ),
                ),
              ),
            ),
            if (badge.isNotEmpty)
              Positioned(
                top: 0,
              right: 0,
              width: w,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _horizontalRow({
    bool showRank = false,
    List<String>? badges,
    List<String>? images,
    double scale = 1.0,
  }) {
    return SizedBox(
      height: 224 * scale,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16, right: 6),
        itemBuilder: (ctx, i) {
          final badge = badges != null && badges.isNotEmpty
              ? badges[i % badges.length]
              : '${3 + (i % 6)} ${LanguageManager.instance.get("Free Episodes")}';
          final imagePath = images != null && images.isNotEmpty
              ? images[i % images.length]
              : 'assets/series${(i % 5) + 1}.png';
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _portraitCard(
              context: ctx,
              imagePath: imagePath,
              badge: badge,
              showRank: showRank,
              rank: i + 1,
              isVideo: i % 4 == 3 || i % 3 == 2,
              index: i,
              scale: scale,
            ),
          );
        },
      ),
    );
  }

  Widget _comingSoonRow(BuildContext context) {
    return SizedBox(
      height: 175,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16, right: 6),
        itemBuilder: (ctx, i) {
          return GestureDetector(
            onTap: () {
              final imageKey = 'assets/series${(i % 5) + 1}.png';
              final details = _getVideoDetailsForImage(imageKey);
              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => VideoPlayerPage(
                      videoId: '',
                      videoUrl: details['video']!,
                      title: details['title']!,
                      showControls: true,
                  ),
                ),
              );
            },
            child: Container(
              width: 220,
              height: 175,
              margin: const EdgeInsets.only(right: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    i % 3 == 2
                        ? _VideoThumbnail(assetPath: _getVideoDetailsForImage('assets/series${(i % 5) + 1}.png')['video']!)
                        : Image.asset(
                            'assets/series${(i % 5) + 1}.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: const Color(0xFF1A1A1A)),
                          ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black87],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 8,
                      right: 8,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    color: Color(0xFFFFD700), size: 10),
                                const SizedBox(width: 4),
                                Text(LanguageManager.instance.get('Coming Soon'),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text(LanguageManager.instance.get('You will be notified')),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.notifications_none, size: 11, color: Colors.black),
                                  const SizedBox(width: 4),
                                  Text(LanguageManager.instance.get('Notify'),
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.black)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _popularGenres() {
    final list = [
      {
        'colors': [const Color(0xFF8B0000), const Color(0xFF4A0000)],
        'image': 'assets/drama.jpeg',
        'name': 'Drama',
      },
      {
        'colors': [const Color(0xFF004D40), const Color(0xFF002420)],
        'image': 'assets/comedy.jpeg',
        'name': 'Comedy',
      },
      {
        'colors': [const Color(0xFF1A1A1A), Colors.black],
        'image': 'assets/thriller.jpeg',
        'name': 'Thriller',
      },
      {
        'colors': [const Color(0xFF4A148C), const Color(0xFF311B92)],
        'image': 'assets/romcom.jpeg',
        'name': 'Romcom',
      },
      {
        'colors': [const Color(0xFF1B5E20), const Color(0xFF0A3D0A)],
        'image': 'assets/feelgood.jpeg',
        'name': 'Feel Good',
      },
    ];

    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16, right: 6),
        itemCount: list.length,
        itemBuilder: (ctx, i) {
          final colors = list[i]['colors'] as List<Color>;
          final image = list[i]['image'] as String;
          final name = list[i]['name'] as String;
          return GestureDetector(
            onTap: () {
              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => GenreDetailsPage(genreName: name),
                ),
              );
            },
            child: Container(
              width: 160,
              height: 95,
              margin: const EdgeInsets.only(right: 12),
              child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: colors,
                      ),
                    ),
                  ),
                  Image.asset(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ],
              ),
            ),
            ),
          );
        },
      ),
    );
  }

  Widget _allShowsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.7,
        ),
        itemBuilder: (gridCtx, i) {
          return GestureDetector(
            onTap: () {
              final imageKey = 'assets/series${(i % 5) + 1}.png';
              final details = _getVideoDetailsForImage(imageKey);
              Navigator.push(
                gridCtx,
                MaterialPageRoute(
                  builder: (_) => VideoPlayerPage(
                      videoId: '',
                      videoUrl: details['video']!,
                      title: details['title']!,
                      showControls: true,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.asset(
                  'assets/series${(i % 5) + 1}.png',
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, __, ___) =>
                      Container(color: const Color(0xFF1A1A1A)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _brandStorySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LanguageManager.instance.get('What is Chai Shots?'),
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            LanguageManager.instance.get('Chai Shots description'),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            LanguageManager.instance.get('Creator-First OTT'),
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We don\'t just showcase shows. We celebrate the people who make them. With our unique "Clap" feature, you can directly support writers, directors, and actors.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqSection() {
    final faqs = [
      {
        'q': 'What is a Short Series?',
        'a': 'Quick, powerful episodes under two minutes each. Layered stories in bite-sized bursts.'
      },
      {
        'q': 'What is Clap?',
        'a': 'It lets you directly show appreciation to the cast and crew with both words and money.'
      },
      {
        'q': 'Is there a subscription?',
        'a': 'Yes! Go unlimited with our subscription plan for ₹99/month.'
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LanguageManager.instance.get('FAQs'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...faqs.map((faq) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  faq['q']!,
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  faq['a']!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _quizSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF001F54),
              Color(0xFF000814),
            ],
          ),
          border: Border.all(color: Colors.white12, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background painter
              Positioned.fill(
                child: CustomPaint(
                  painter: _QuizBackgroundPainter(),
                ),
              ),
              // Full-cover Image
              Positioned.fill(
                child: Image.asset(
                  'assets/quiz_banner.jpeg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.quiz, color: Colors.white24, size: 80),
                  ),
                ),
              ),
              // Fade out the bottom of the image to hide the baked-in button graphic
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 90,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xD9000814),
                        Color(0xFF000814),
                      ],
                      stops: [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
              // Button overlaid on the image at the bottom
              Positioned(
                left: 24,
                right: 24,
                bottom: 16,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QuizProfilePage()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF000814),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      LanguageManager.instance.get('Join the quiz'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
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

  Widget _howItWorksSection() {
    final steps = [
      {'icon': Icons.flash_on, 'text': 'Regional Stories told in 2-min bursts.'},
      {'icon': Icons.auto_stories, 'text': '10-100 episodes for a deep binge.'},
      {'icon': Icons.thumb_up_alt_outlined, 'text': 'Clap to support your favorite stars.'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LanguageManager.instance.get('How Chai Shots Works'),
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...steps.map((step) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(step['icon'] as IconData, color: const Color(0xFFFFD700), size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    step['text'] as String,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _creatorFocusSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text(
            'India\'s First Creator-First OTT',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We celebrate the writers, directors, and actors who bring stories to life. Your "Claps" go directly to them.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _creatorAvatar('assets/series1.png'),
              _creatorAvatar('assets/series2.png'),
              _creatorAvatar('assets/series3.png'),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.add, color: Colors.black, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _creatorAvatar(String path) {
    return Align(
      widthFactor: 0.7,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 2),
          image: DecorationImage(image: AssetImage(path), fit: BoxFit.cover),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.6),
        elevation: 0,
        toolbarHeight: 65,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset('assets/chaishots_logo_white.png', height: 45),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white38),
            ),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LanguagePage()),
              ),
              child: Row(
                children: [
                  Text(
                      LanguageManager.instance.displayLanguage.value == "Telugu"
                          ? "తెలుగు"
                          : LanguageManager.instance.displayLanguage.value,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: Colors.yellow,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.yellow.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 26, height: 26,
                    decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                    child: const Icon(Icons.workspace_premium, color: Color(0xFFFFD400), size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Go Premium',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80, top: 65),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const _HeroCarousel(),
              const SizedBox(height: 10),
              _quizSection(context),
              const SizedBox(height: 28),

              _sectionTitle('Trending'),
              const SizedBox(height: 12),
              _horizontalRow(
                showRank: true,
                badges: const [
                  '1 Free Episode', '3 Free Episodes', '5 Free Episodes',
                  '2 Free Episodes', '4 Free Episodes', '6 Free Episodes',
                ],
              ),
              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: const BoxDecoration(color: Colors.black),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/coming_soon_calendar.png', height: 40,
                        errorBuilder: (ctx, __, ___) => const Icon(Icons.calendar_today, color: Color(0xFFFFD700), size: 30)),
                    const SizedBox(width: 20),
                    Text(
                      LanguageManager.instance.get('Coming Soon').toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w400, letterSpacing: 4),
                    ),
                    const SizedBox(width: 20),
                    Image.asset('assets/coming_soon_clapper.png', height: 40,
                        errorBuilder: (ctx, __, ___) => const Icon(Icons.movie_creation, color: Color(0xFFFFD700), size: 30)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _comingSoonRow(context),
              const SizedBox(height: 28),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: const _VideoThumbnail(
                    assetPath: 'assets/alltimeblockbusters.mp4',
                    useOriginalAspectRatio: true,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              _horizontalRow(
                badges: const ['', '', '', '', '', ''],
                scale: 0.75,
              ),
              const SizedBox(height: 28),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(image: AssetImage('assets/theater_curtains.png'), fit: BoxFit.cover),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.4), Colors.transparent, Colors.black.withOpacity(0.6)],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('SHOWS', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 4.0,
                            shadows: [Shadow(color: Colors.black.withOpacity(0.8), offset: const Offset(2, 2), blurRadius: 10)])),
                        Text('OF THE WEEK', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _horizontalRow(),
              const SizedBox(height: 28),

              _sectionTitle('Drama'),
              const SizedBox(height: 12),
              _horizontalRow(badges: const ['3 Free Episodes', '3 Free Episodes', '4 Free Episodes', '2 Free Episodes', '5 Free Episodes', '3 Free Episodes']),
              const SizedBox(height: 28),

              _sectionTitle('Rom-Com'),
              const SizedBox(height: 12),
              _horizontalRow(badges: const ['3 Free Episodes', '3 Free Episodes', '4 Free Episodes', '2 Free Episodes', '5 Free Episodes', '3 Free Episodes']),
              const SizedBox(height: 28),

              _sectionTitle('New Releases'),
              const SizedBox(height: 12),
              _horizontalRow(badges: const ['5 Free Episodes', '2 Free Episodes', '3 Free Episodes', '4 Free Episodes', '1 Free Episode', '3 Free Episodes']),
              const SizedBox(height: 28),

              _sectionTitle('18+'),
              const SizedBox(height: 12),
              _horizontalRow(badges: const ['3 Free Episodes', '2 Free Episodes', '4 Free Episodes', '3 Free Episodes', '2 Free Episodes', '5 Free Episodes']),
              const SizedBox(height: 28),

              _sectionTitle('GenZ Vibes'),
              const SizedBox(height: 12),
              _horizontalRow(badges: const ['3 Free Episodes', '5 Free Episodes', '4 Free Episodes', '3 Free Episodes', '2 Free Episodes', '3 Free Episodes']),
              const SizedBox(height: 28),

              _sectionTitle('Binge in 30 Min'),
              const SizedBox(height: 12),
              _horizontalRow(badges: const ['5 Free Episodes', '3 Free Episodes', '4 Free Episodes', '2 Free Episodes', '5 Free Episodes', '3 Free Episodes']),
              const SizedBox(height: 28),

              _sectionTitle('Short Serials'),
              const SizedBox(height: 12),
              _horizontalRow(badges: const ['5 Free Episodes', '3 Free Episodes', '4 Free Episodes', '2 Free Episodes', '3 Free Episodes', '5 Free Episodes']),
              const SizedBox(height: 28),

              _sectionTitle('Thriller'),
              const SizedBox(height: 12),
              _horizontalRow(badges: const ['2 Free Episodes', '1 Free Episode', '3 Free Episodes', '2 Free Episodes', '4 Free Episodes', '3 Free Episodes']),
              const SizedBox(height: 28),

              _sectionTitle('Comedy'),
              const SizedBox(height: 12),
              _horizontalRow(badges: const ['5 Free Episodes', '8 Free Episodes', '3 Free Episodes', '4 Free Episodes', '2 Free Episodes', '5 Free Episodes']),
              const SizedBox(height: 28),

              _sectionTitle('Popular Genres'),
              const SizedBox(height: 12),
              _popularGenres(),
              const SizedBox(height: 28),

              _sectionTitle('All Shows'),
              const SizedBox(height: 12),
              _allShowsGrid(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

// ── BOTTOM NAV ITEM ─────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({required this.icon, required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.yellow : Colors.grey;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }
}

// ── HERO CAROUSEL ───────────────────────────────────────────────
class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel();

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  PageController? _ctrl;
  double _page = 10000;

  // Map each card to its image and video
  List<Map<String, String>> get _items => [
    {'image': 'assets/series1.png', 'video': 'assets/thecult.mp4',     'title': 'THE CULT'},
    {'image': 'assets/series2.png', 'video': 'assets/30weds21.mp4',    'title': '30 WEDS 21'},
    {'image': 'assets/series3.png', 'video': 'assets/english.mp4',     'title': 'ENGLISH MADAM PT SIR'},
    {'image': 'assets/series4.png', 'video': 'assets/janaejigars.mp4', 'title': 'JAANE JIGARS'},
    {'image': 'assets/series5.png', 'video': 'assets/meow.mp4',     'title': 'MEOW'},
  ];

  final List<String> _badges = [
    '1 Free Episode', '2 Free Episodes', '3 Free Episodes', '4 Free Episodes',
    '5 Free Episodes', '6 Free Episodes', '7 Free Episodes', '8 Free Episodes',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(viewportFraction: 0.42, initialPage: 10000);
    _ctrl?.addListener(() {
      if (mounted && _ctrl != null && _ctrl!.hasClients) {
        setState(() => _page = _ctrl?.page ?? 0);
      }
    });
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double cardW = 140;
    const double cardH = 260;
    const double pillOverhang = 8.0;

    return SizedBox(
      height: cardH + pillOverhang + 26,
      child: PageView.builder(
        controller: _ctrl,
        itemBuilder: (ctx, i) {
          final int realIndex = i % _items.length;
          final scale   = (1 - (_page - i).abs() * 0.15).clamp(0.82, 1.0);
          final opacity = (1 - (_page - i).abs() * 0.5).clamp(0.4, 1.0);
          final item    = _items[realIndex];

          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoPlayerPage(
                          videoId: '',
                          videoUrl: item['video']!,
                          title: item['title']!,
                          showControls: true,
                        ),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: cardW,
                    height: cardH + pillOverhang,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        // ── Card with image ──────────────────────
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            width: cardW,
                            height: cardH,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFFFFD700), width: 1.5),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _CarouselVideoPlayer(
                                videoPath: item['video']!,
                                imagePath: item['image']!,
                                isActive: _page.round() == i,
                              ),
                            ),
                          ),
                        ),

                        // ── Badge pill ───────────────────────────
                        Positioned(
                          top: 0,
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD700),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                const [
                                  '1 Free Episode', '3 Free Episodes', '5 Free Episodes',
                                  '2 Free Episodes', '4 Free Episodes', '6 Free Episodes',
                                ][i % 6],
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                      ],
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
}

// ── CAROUSEL VIDEO PLAYER ───────────────────────────────────────
class _CarouselVideoPlayer extends StatefulWidget {
  final String videoPath;
  final String imagePath;
  final bool isActive;
  const _CarouselVideoPlayer({
    required this.videoPath,
    required this.imagePath,
    required this.isActive,
  });

  @override
  State<_CarouselVideoPlayer> createState() => _CarouselVideoPlayerState();
}

class _CarouselVideoPlayerState extends State<_CarouselVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isMuted = true;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _initVideo();
    }
  }

  void _initVideo() {
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        if (mounted) {
          _controller?.setVolume(_isMuted ? 0 : 1);
          _controller?.setLooping(true);
          _controller?.play();
          setState(() {});
        }
      });
  }

  void _disposeVideo() {
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
  }

  @override
  void didUpdateWidget(covariant _CarouselVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoPath != oldWidget.videoPath && widget.isActive) {
      _disposeVideo();
      _initVideo();
    } else if (widget.isActive && !oldWidget.isActive) {
      _initVideo();
    } else if (!widget.isActive && oldWidget.isActive) {
      _disposeVideo();
    }
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showVideo = widget.isActive &&
        _controller != null &&
        _controller!.value.isInitialized;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          widget.imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Container(color: const Color(0xFF1A1A1A)),
        ),
        if (showVideo)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
        if (widget.isActive)
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isMuted = !_isMuted;
                  _controller?.setVolume(_isMuted ? 0 : 1);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── VIDEO THUMBNAIL ─────────────────────────────────────────────
class _VideoThumbnail extends StatefulWidget {
  final String assetPath;
  final bool useOriginalAspectRatio;
  const _VideoThumbnail({super.key, required this.assetPath, this.useOriginalAspectRatio = false});

  @override
  State<_VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<_VideoThumbnail> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller?.setLooping(true);
          _controller?.setVolume(0);
          _controller?.play();
        }
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return Container(color: Colors.black26);
    }
    if (widget.useOriginalAspectRatio) {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: VideoPlayer(controller),
      );
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}

// ── GENRE DETAILS PAGE ──────────────────────────────────────────
class GenreDetailsPage extends StatelessWidget {
  final String genreName;

  const GenreDetailsPage({super.key, required this.genreName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          LanguageManager.instance.get(genreName),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: 12,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (context, i) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VideoPlayerPage(
                      videoId: '',
                      videoUrl: i % 4 == 3
                          ? 'assets/meow.mp4'
                          : (i % 4 == 0 ? 'assets/janaejigars.mp4' : (i % 4 == 1 ? 'assets/english.mp4' : 'assets/30weds21.mp4')),
                      title: i % 4 == 3
                          ? 'MEE OWW'
                          : (i % 4 == 0 ? 'JAANE JIGARS' : (i % 4 == 1 ? 'RATNAMALA' : 'ENGLISH MADAM PT SIR')),
                      showControls: true,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/series${(i % 5) + 1}.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A1A1A)),
                      ),
                      if (i % 3 == 1)
                        const Center(
                          child: Icon(Icons.play_circle_outline, color: Colors.white70, size: 50),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── VIDEO PLAYER PAGE ───────────────────────────────────────────
// Removed redundant VideoPlayerPage

// ── QUIZ BACKGROUND PAINTER ─────────────────────────────────────
class _QuizBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    final path = Path();
    const double step = 40;
    for (double i = -step; i < size.width + step; i += step) {
      for (double j = -step; j < size.height + step; j += step) {
        path.moveTo(i, j);
        path.lineTo(i + step, j + step);
        path.lineTo(i, j + step * 2);
        path.close();
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
