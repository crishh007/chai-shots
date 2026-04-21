import 'package:flutter/material.dart';
import '../home_page.dart';
import 'profile_screen.dart';
import '../language_manager.dart';
import 'search_screen.dart';
import 'discover_screen.dart';
import 'shelf_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const HomePage(),
    const OttSearchScreen(),
    const DiscoverPage(),
    const ShelfPage(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final lm = LanguageManager.instance;
    return ValueListenableBuilder<String>(
      valueListenable: lm.displayLanguage,
      builder: (context, lang, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: _pages[_currentIndex],
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.black,
              elevation: 0,
              selectedItemColor: const Color(0xFFFFD400),
              unselectedItemColor: Colors.white38,
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedFontSize: 11,
              unselectedFontSize: 11,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined), 
                  activeIcon: const Icon(Icons.home), 
                  label: lm.get("Home"),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.search), 
                  label: lm.get("Search"),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.video_library),
                  label: 'Discover',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.favorite_outline), 
                  activeIcon: const Icon(Icons.favorite), 
                  label: lm.get("Shelf"),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline), 
                  activeIcon: const Icon(Icons.person), 
                  label: lm.get("Profile"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
