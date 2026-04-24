import 'package:flutter/material.dart';
import 'quiz_home_page.dart';

class SpectatorPage extends StatelessWidget {
  const SpectatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 80,
        leading: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Help',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header with stars
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Color(0xFFFFD700), size: 14),
                SizedBox(width: 4),
                Icon(Icons.star, color: Color(0xFFFFD700), size: 18),
                SizedBox(width: 4),
                Icon(Icons.star, color: Color(0xFFFFD700), size: 22),
                SizedBox(width: 4),
                Icon(Icons.star, color: Color(0xFFFFD700), size: 18),
                SizedBox(width: 4),
                Icon(Icons.star, color: Color(0xFFFFD700), size: 14),
              ],
            ),
            const SizedBox(height: 12),
            // logo placeholder area
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Image.asset('assets/image.png', height: 40),
                 const SizedBox(width: 12),
                 const Text('PRESENTS', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.5)),
              ],
            ),
            const SizedBox(height: 24),

            // Results Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3), width: 1.5),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Curtain/Theatrical feel (simplified with colors)
                    Positioned(
                      top: 0,
                      child: Container(
                        width: 400,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.red.withOpacity(0.2), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          // Character Image
                          SizedBox(
                            height: 180,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Image.asset(
                                  'assets/quiz_sad_grandma.png',
                                  height: 160,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '0/10',
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'BETTER LUCK NEXT TIME',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Winners Board
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(child: Divider(color: Colors.white10)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Winners Board',
                        style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(child: Divider(color: Colors.white10)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Extended List of Winners
            ...List.generate(12, (index) => _winnerTile(
              [
                'Tarun', 'Rameshwari', 'Venkat', 'Sumanth.K', 'Anusha', 'Gayathri', 
                'Satish koppanathi', 'Subhash', 'Rammmm', 'Aditya Reddy', 'Appu', 'Rakesh.ms'
              ][index % 12], 
              '₹416'
            )),

            const SizedBox(height: 24),
            
            // Bottom Take me home button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QuizHomePage()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Take me home',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _winnerTile(String name, String amount) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 18),
          ),
          const SizedBox(width: 16),
          Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            amount,
            style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
