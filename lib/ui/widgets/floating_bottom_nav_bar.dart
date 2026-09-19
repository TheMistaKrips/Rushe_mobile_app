import 'dart:ui';
import 'package:flutter/material.dart';
import 'neat_gradient_bg.dart';

class FloatingBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FloatingBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // We have 4 items
          final double itemWidth = constraints.maxWidth / 4;
          
          return Container(
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: Stack(
                children: [
                  // Animated gradient background for the menu block
                  const Positioned.fill(
                    child: NeatGradientBg(
                      borderRadius: 35.0,
                      child: SizedBox(),
                    ),
                  ),
                  // Darken it slightly so icons are visible
                  Positioned.fill(
                    child: Container(color: Colors.black.withOpacity(0.3)),
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Stack(
                      children: [
                        // Animated bubble
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    left: currentIndex * itemWidth + (itemWidth / 2) - 25,
                    top: 10,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF9D88F2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9D88F2).withOpacity(0.4),
                            blurRadius: 15,
                            spreadRadius: 2,
                          )
                        ]
                      ),
                    ),
                  ),
                  // Icons Row
                  Row(
                    children: [
                      _buildNavItem(0, Icons.home_rounded, itemWidth),
                      _buildNavItem(1, Icons.explore_outlined, itemWidth),
                      _buildNavItem(2, Icons.library_music_outlined, itemWidth),
                      _buildNavItem(3, Icons.settings_outlined, itemWidth),
                    ],
                  ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, double width) {
    final isSelected = currentIndex == index;
    
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        height: 70,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              icon,
              key: ValueKey<bool>(isSelected),
              color: isSelected ? Colors.white : Colors.white60,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
