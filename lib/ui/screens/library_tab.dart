import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/library_provider.dart';
import '../../providers/player_provider.dart';

class LibraryTab extends StatelessWidget {
  const LibraryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Лайки'),
                Tab(text: 'Плейлисты'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildLikesTab(),
                  _buildPlaylistsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikesTab() {
    return Consumer<LibraryProvider>(
      builder: (context, library, child) {
        final likes = library.likedTracks;
        if (likes.isEmpty) {
          return const Center(child: Text('Нет любимых треков'));
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 120, top: 16),
          itemCount: likes.length,
          itemBuilder: (context, index) {
            final track = likes[index];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: track.thumbnailUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(track.author, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                icon: Icon(Icons.favorite, color: Theme.of(context).primaryColor),
                onPressed: () => library.toggleLike(track),
              ),
              onTap: () {
                context.read<PlayerProvider>().loadPlaylist(likes, startIndex: index);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPlaylistsTab() {
    return Consumer<LibraryProvider>(
      builder: (context, library, child) {
        final playlists = library.playlists;
        if (playlists.isEmpty) {
          return const Center(child: Text('Нет плейлистов'));
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 120, top: 16),
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            final playlist = playlists[index];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: playlist.coverUrl.isNotEmpty 
                      ? playlist.coverUrl 
                      : 'https://via.placeholder.com/50',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(playlist.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('\${playlist.tracks.length} треков'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => library.deletePlaylist(playlist.id),
              ),
              onTap: () {
                if (playlist.tracks.isNotEmpty) {
                  context.read<PlayerProvider>().loadPlaylist(playlist.tracks);
                }
              },
            );
          },
        );
      },
    );
  }
}
