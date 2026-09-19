import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/player_provider.dart';
import '../screens/full_player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  void _openFullScreenPlayer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FullPlayerScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, player, child) {
        final mediaItem = player.currentMediaItem;
        if (mediaItem == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => _openFullScreenPlayer(context),
          child: Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1A2D).withOpacity(0.95), // Deep dark purple
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: mediaItem.artUri.toString(),
                          fit: BoxFit.cover,
                          errorWidget: (c,u,e) => Container(
                            color: const Color(0xFF9D88F2).withOpacity(0.2), 
                            child: const Icon(Icons.music_note, color: Color(0xFF9D88F2))
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            mediaItem.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            mediaItem.artist ?? 'Неизвестный исполнитель',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.favorite_border, color: Colors.white.withOpacity(0.6), size: 24),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(
                        player.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, 
                        size: 40, 
                        color: const Color(0xFF9D88F2) // Soft purple instead of green
                      ),
                      onPressed: player.isPlaying ? player.pause : player.play,
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
