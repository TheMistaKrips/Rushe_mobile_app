import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/youtube_api_service.dart';
import '../../models/track.dart';
import '../../providers/player_provider.dart';
import '../../providers/library_provider.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _searchController = TextEditingController();
  final YoutubeApiService _apiService = YoutubeApiService();
  
  List<Track> _results = [];
  bool _isLoading = false;

  void _search() async {
    if (_searchController.text.trim().isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _results = [];
    });
    
    final results = await _apiService.searchTracks(_searchController.text.trim());
    
    if (mounted) {
      setState(() {
        _results = results;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _results = []);
                  },
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator())),
          if (!_isLoading && _results.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 120, left: 16, right: 16),
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final track = _results[index];
                  return Consumer<LibraryProvider>(
                    builder: (context, library, child) {
                      final isLiked = library.isLiked(track.id);
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
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Theme.of(context).primaryColor : null,
                          ),
                          onPressed: () => library.toggleLike(track),
                        ),
                        onTap: () {
                          context.read<PlayerProvider>().loadPlaylist(_results, startIndex: index);
                        },
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
