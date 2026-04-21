import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/content_model.dart';

class ShareSheet extends StatelessWidget {
  final ContentModel video;

  const ShareSheet({super.key, required this.video});

  void _shareApp(BuildContext context, String platform) {
    Share.share("Check out this amazing video on Chai Shots: ${video.title}\n\n${video.shareUrl}");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Share",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white, size: 24)),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                video.thumbnail,
                width: 180,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  width: 180,
                  height: 180,
                  color: video.bgColor,
                  child: Center(
                    child: Text(
                      video.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: TextEditingController(text: video.shareUrl),
                      readOnly: true,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: video.shareUrl));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("✅ Link copied!")));
                  },
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: const BoxDecoration(
                      color: Color(0xFF3A3A3A),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Copy",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () => _shareApp(context, 'Facebook'),
                child: const Column(mainAxisSize: MainAxisSize.min, children: [
                  CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xFF1877F2),
                      child: Text("f",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold))),
                  SizedBox(height: 6),
                  Text("Facebook",
                      style: TextStyle(color: Colors.white, fontSize: 11)),
                ]),
              ),
              GestureDetector(
                onTap: () => _shareApp(context, 'Stories'),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                              colors: [
                                Color(0xFFF58529),
                                Color(0xFFDD2A7B),
                                Color(0xFF8134AF),
                                Color(0xFF515BD4)
                              ],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight)),
                      child: const Icon(Icons.camera_alt_outlined,
                          color: Colors.white, size: 26)),
                  const SizedBox(height: 6),
                  const Text("Stories",
                      style: TextStyle(color: Colors.white, fontSize: 11)),
                ]),
              ),
              GestureDetector(
                onTap: () => _shareApp(context, 'WhatsApp'),
                child: const Column(mainAxisSize: MainAxisSize.min, children: [
                  CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xFF25D366),
                      child: Icon(Icons.chat_bubble_outline,
                          color: Colors.white, size: 26)),
                  SizedBox(height: 6),
                  Text("WhatsApp",
                      style: TextStyle(color: Colors.white, fontSize: 11)),
                ]),
              ),
              GestureDetector(
                onTap: () => _shareApp(context, 'Twitter'),
                child: const Column(mainAxisSize: MainAxisSize.min, children: [
                  CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xFF555555),
                      child: Icon(Icons.close, color: Colors.white, size: 26)),
                  SizedBox(height: 6),
                  Text("Twitter / X",
                      style: TextStyle(color: Colors.white, fontSize: 11)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _shareApp(context, 'More'),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[700],
                  child: const Text("•••",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          letterSpacing: 2))),
              const SizedBox(height: 6),
              const Text("More",
                  style: TextStyle(color: Colors.white, fontSize: 11)),
            ]),
          ),
        ],
      ),
    );
  }
}
