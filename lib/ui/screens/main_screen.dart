import 'package:flutter/material.dart';
import '../widgets/floating_bottom_nav_bar.dart';
import '../widgets/mini_player.dart';
import '../widgets/animated_blur_background.dart';
import 'home_tab.dart';
import 'search_tab.dart';
import 'library_tab.dart';
import 'settings_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeTab(),
    SearchTab(),
    LibraryTab(),
    SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C16), // Slightly lighter, deep dark purple/grey
      body: Stack(
        children: [
          // Content
          IndexedStack(
            index: _currentIndex,
            children: _tabs,
          ),
          // Floating Elements (Player + Nav)
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MiniPlayer(),
                FloatingBottomNavBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
