import 'package:flutter/material.dart';
import '../screens/clap_payment_screen.dart';

class ClapBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> castList;
  final List<Map<String, dynamic>> crewList;

  const ClapBottomSheet({
    super.key,
    required this.castList,
    required this.crewList,
  });

  @override
  State<ClapBottomSheet> createState() => _ClapBottomSheetState();
}

class _ClapBottomSheetState extends State<ClapBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF151515),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.only(top: 20, bottom: 40),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Send Clap",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF2C2C2C)),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Support Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF38105B), Color(0xFF6B1E94)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Support your fav", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        Text("creator with a clap", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ClapInfoScreen()));
                      },
                      child: Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text("Know more", style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text("Cast", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.castList.length,
                itemBuilder: (context, index) {
                  final member = widget.castList[index];
                  return _buildMemberCard(member);
                },
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text("Crew", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.crewList.length,
                itemBuilder: (context, index) {
                  final member = widget.crewList[index];
                  return _buildMemberCard(member);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(8), // Reduced padding to fix the 4 pixel overflow
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Color(member['color']),
            radius: 26,
            backgroundImage: member['imageUrl'] != null && member['imageUrl'].toString().isNotEmpty
                ? NetworkImage(member['imageUrl'])
                : null,
            child: member['imageUrl'] == null || member['imageUrl'].toString().isEmpty
                ? Text(member['name'].substring(0, 1),
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))
                : null,
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(member['name'],
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 2),
          Text(member['role'],
              style: const TextStyle(color: Colors.white54, fontSize: 10)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Navigator.pop(context); // Ensure the bottom sheet closes
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClapPaymentScreen(
                    creator: member,
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6), // Slightly reduced to fit gracefully
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.front_hand, size: 14, color: Colors.black),
                  SizedBox(width: 4),
                  Text("Clap", style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class ClapInfoScreen extends StatelessWidget {
  const ClapInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Clap Feature", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Clap ante?", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text(
              "Simple ga cheppalante, it's your way to say 'Well done ra!' to the cast & crew.\n\nClap = appreciation note + money for the young creators to do more!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Let's Clap!", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
