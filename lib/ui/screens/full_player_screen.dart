import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/player_provider.dart';
import '../../providers/library_provider.dart';
import '../../models/track.dart';

class FullPlayerScreen extends StatefulWidget {
  const FullPlayerScreen({super.key});

  @override
  State<FullPlayerScreen> createState() => _FullPlayerScreenState();
}

class _FullPlayerScreenState extends State<FullPlayerScreen> {
  bool _isShuffle = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      body: Consumer<PlayerProvider>(
        builder: (context, player, child) {
          final mediaItem = player.currentMediaItem;
          if (mediaItem == null) {
            return const Center(child: Text('Нет медиа', style: TextStyle(color: Colors.white)));
          }

          final position = player.currentPosition;
          final duration = mediaItem.duration ?? const Duration(minutes: 3);

          return Stack(
            children: [
              // Background blurred image
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: mediaItem.artUri?.toString() ?? '',
                  fit: BoxFit.cover,
                  errorWidget: (c,u,e) => Container(color: const Color(0xFF1E1A2D)),
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
              
              // Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 36),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          const Text(
                            'Сейчас играет',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Consumer<LibraryProvider>(
                            builder: (context, library, child) {
                              final isLiked = library.isLiked(mediaItem.id);
                              return IconButton(
                                icon: Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: isLiked ? const Color(0xFF9D88F2) : Colors.white, 
                                  size: 28
                                ),
                                onPressed: () {
                                  final track = Track(
                                    id: mediaItem.id,
                                    title: mediaItem.title,
                                    author: mediaItem.artist ?? 'Неизвестно',
                                    thumbnailUrl: mediaItem.artUri?.toString() ?? '',
                                    durationMs: mediaItem.duration?.inMilliseconds ?? 0,
                                  );
                                  library.toggleLike(track);
                                  setState(() {}); // Force rebuild if provider doesn't notify correctly
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Artwork
                      Hero(
                        tag: 'album_art_\${mediaItem.id}',
                        child: Container(
                          width: MediaQuery.of(context).size.width - 48,
                          height: MediaQuery.of(context).size.width - 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.6),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: CachedNetworkImage(
                              imageUrl: mediaItem.artUri?.toString() ?? '',
                              fit: BoxFit.cover,
                              errorWidget: (c,u,e) => Container(color: Colors.grey[800], child: const Icon(Icons.music_note, size: 100, color: Colors.white)),
                            ),
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Track Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mediaItem.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  mediaItem.artist ?? 'Неизвестный исполнитель',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
                            onPressed: () {
                              _showAddToPlaylistModal(context, Track(
                                id: mediaItem.id,
                                title: mediaItem.title,
                                author: mediaItem.artist ?? 'Неизвестно',
                                thumbnailUrl: mediaItem.artUri?.toString() ?? '',
                                durationMs: mediaItem.duration?.inMilliseconds ?? 0,
                              ));
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Progress Bar
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 4,
                          activeTrackColor: const Color(0xFF9D88F2),
                          inactiveTrackColor: Colors.white.withOpacity(0.2),
                          thumbColor: const Color(0xFF9D88F2),
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                        ),
                        child: Slider(
                          value: position.inMilliseconds.toDouble().clamp(0.0, duration.inMilliseconds.toDouble()),
                          max: duration.inMilliseconds.toDouble() > 0 ? duration.inMilliseconds.toDouble() : 1.0,
                          onChanged: (val) {
                            player.seek(Duration(milliseconds: val.toInt()));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(position),
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(Icons.shuffle, color: _isShuffle ? const Color(0xFF9D88F2) : Colors.white, size: 28),
                            onPressed: () {
                              setState(() {
                                _isShuffle = !_isShuffle;
                              });
                              player.toggleShuffle(_isShuffle);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 40),
                            onPressed: player.skipToPrevious,
                          ),
                          GestureDetector(
                            onTap: player.isPlaying ? player.pause : player.play,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: Color(0xFF9D88F2),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x669D88F2),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  )
                                ]
                              ),
                              child: Icon(
                                player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.black,
                                size: 40,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 40),
                            onPressed: player.skipToNext,
                          ),
                          IconButton(
                            icon: const Icon(Icons.repeat, color: Colors.white, size: 28),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddToPlaylistModal(BuildContext context, Track track) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E182A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Consumer<LibraryProvider>(
          builder: (context, library, child) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Добавить в плейлист', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  if (library.playlists.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('У вас пока нет плейлистов', style: TextStyle(color: Colors.grey)),
                    ),
                  ...library.playlists.map((pl) => ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.queue_music, color: Color(0xFF9D88F2)),
                    ),
                    title: Text(pl.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('\${pl.tracks.length} треков', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                    onTap: () {
                      library.addTrackToPlaylist(pl.id, track);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Добавлено в \${pl.name}', style: const TextStyle(color: Colors.white)),
                        backgroundColor: const Color(0xFF9D88F2),
                        behavior: SnackBarBehavior.floating,
                      ));
                    },
                  )),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.grey, height: 1),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9D88F2).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add, color: Color(0xFF9D88F2)),
                    ),
                    title: const Text('Создать новый', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.pop(context);
                      _createNewPlaylist(context, library, track);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _createNewPlaylist(BuildContext context, LibraryProvider library, Track track) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E182A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Новый плейлист', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Название', 
            hintStyle: const TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF9D88F2))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await library.createPlaylist(controller.text, track.thumbnailUrl);
                final newPlaylist = library.playlists.last;
                await library.addTrackToPlaylist(newPlaylist.id, track);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Создано и добавлено в \${controller.text}'),
                    backgroundColor: const Color(0xFF9D88F2),
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              }
            },
            child: const Text('Создать', style: TextStyle(color: Color(0xFF9D88F2), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "\$twoDigitMinutes:\$twoDigitSeconds";
  }
}
