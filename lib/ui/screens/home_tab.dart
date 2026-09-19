import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/player_provider.dart';
import '../../services/youtube_api_service.dart';
import '../../models/track.dart';
import '../widgets/neat_gradient_bg.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final YoutubeApiService _apiService = YoutubeApiService();
  int _selectedCategory = 0;
  final List<String> _categories = ['Все', 'Новинки', 'В тренде', 'Топ'];

  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  List<Track> _searchResults = [];
  bool _isSearching = false;

  bool _isCategoryLoading = false;
  bool _isMyWaveLoading = false;
  bool _isMyWavePressed = false;
  
  List<Track> _popularTracks = [];
  bool _isPopularLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPopularTracks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadPopularTracks() async {
    final tracks = await _apiService.searchTracks("популярные песни хит 2024");
    if (mounted) {
      setState(() {
        _popularTracks = tracks;
        _isPopularLoading = false;
      });
    }
  }

  Future<void> _playCategory(String category) async {
    setState(() => _isCategoryLoading = true);
    final query = "\$category музыка плейлист 2024";
    final tracks = await _apiService.searchTracks(query);
    if (tracks.isNotEmpty && mounted) {
      context.read<PlayerProvider>().loadPlaylist(tracks);
    }
    if (mounted) setState(() => _isCategoryLoading = false);
  }

  Future<void> _playBanner(String query) async {
    setState(() => _isCategoryLoading = true);
    final tracks = await _apiService.searchTracks(query);
    if (tracks.isNotEmpty && mounted) {
      context.read<PlayerProvider>().loadPlaylist(tracks);
    }
    if (mounted) setState(() => _isCategoryLoading = false);
  }

  Timer? _debounce;

  Future<void> _performSearch(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    
    _debounce = Timer(const Duration(milliseconds: 600), () async {
      final tracks = await _apiService.searchTracks(query);
      if (mounted) {
        setState(() {
          _searchResults = tracks;
          _isSearching = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Uses global background from MainScreen
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildHeader(context),
                    const SizedBox(height: 32),
                    _buildCategories(),
                    const SizedBox(height: 32),
                    const Text(
                      'Рекомендуем',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMyWaveCard(),
                    const SizedBox(height: 32),
                    const Text(
                      'Под настроение',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBentoGrid(),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Популярное сейчас',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Все',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPopularTracks(),
                    const SizedBox(height: 120), // Padding for bottom nav
                  ],
                ),
              ),
            ),
            
            // Floating Search Overlay
            if (_isSearchExpanded) _buildSearchOverlay(),

            // Top Progress Bar for Categories/Banners
            if (_isCategoryLoading)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(color: Color(0xFF9D88F2), backgroundColor: Colors.transparent),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchOverlay() {
    return Container(
      color: const Color(0xFF0F0C16).withOpacity(0.95),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      autofocus: true,
                      onChanged: (val) {
                        _performSearch(val);
                      },
                      onSubmitted: _performSearch,
                      decoration: InputDecoration(
                        hintText: 'Поиск...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        prefixIcon: const Icon(Icons.search, color: Colors.white),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults = [];
                            });
                          },
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSearchExpanded = false;
                      _searchController.clear();
                      _searchResults = [];
                    });
                  },
                  child: const Text('Отмена', style: TextStyle(color: Color(0xFF9D88F2), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(color: Color(0xFF9D88F2)),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final track = _searchResults[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(track.thumbnailUrl, width: 50, height: 50, fit: BoxFit.cover),
                  ),
                  title: Text(track.title, style: const TextStyle(color: Colors.white), maxLines: 1),
                  subtitle: Text(track.author, style: TextStyle(color: Colors.white.withOpacity(0.5))),
                  onTap: () {
                    context.read<PlayerProvider>().loadPlaylist([track]);
                    setState(() => _isSearchExpanded = false);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = context.watch<LibraryProvider>().userProfile;
    final name = user?.nickname ?? 'Слушатель';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            image: const DecorationImage(
              image: AssetImage('images/icon.png'), // placeholder for avatar
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Привет, $name',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () => setState(() => _isSearchExpanded = true),
          child: _buildHeaderIcon(Icons.search),
        ),
      ],
    );
  }

  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.05),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }

  Widget _buildCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_categories.length, (index) {
          final isSelected = _selectedCategory == index;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = index);
              _playCategory(_categories[index]);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF9D88F2) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                _categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white.withOpacity(0.6),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMyWaveCard() {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isMyWavePressed = true),
      onTapUp: (_) => setState(() => _isMyWavePressed = false),
      onTapCancel: () => setState(() => _isMyWavePressed = false),
      onTap: () async {
        setState(() => _isMyWaveLoading = true);
        await _playBanner("лучшая музыка микс плейлист");
        if (mounted) setState(() => _isMyWaveLoading = false);
      },
      child: AnimatedScale(
        scale: _isMyWavePressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF1E4E).withOpacity(0.4),
                blurRadius: 35,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: const Color(0xFF8B18D6).withOpacity(0.3),
                blurRadius: 40,
                spreadRadius: -2,
                offset: const Offset(0, 20),
              ),
            ]
          ),
          child: NeatGradientBg(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _isMyWaveLoading 
                              ? const SizedBox(
                                  width: 60, 
                                  height: 60, 
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                                )
                              : const Icon(Icons.play_circle_fill, color: Colors.white, size: 60),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Моя Волна',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Музыка, которая нравится вам',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBentoGrid() {
    return SizedBox(
      height: 240,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildBentoCard('Раннее утро', 'lofi morning coffee', 'banners/coffee.jpeg'),
                ),
                const SizedBox(height: 12),
                Expanded(
                  flex: 2,
                  child: _buildBentoCard('Спортзал', 'workout gym motivation music', 'banners/sport.jpeg'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildBentoCard('Романтика', 'romantic love songs', 'banners/love.jpeg'),
                ),
                const SizedBox(height: 12),
                Expanded(
                  flex: 3,
                  child: _buildBentoCard('Спокойный вечер', 'night chill vibes', 'banners/night.jpeg'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoCard(String title, String query, String imagePath) {
    return GestureDetector(
      onTap: () => _playBanner(query),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularTracks() {
    if (_isPopularLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(color: Color(0xFF9D88F2)),
        ),
      );
    }
    
    if (_popularTracks.isEmpty) {
      return const Text("Не удалось загрузить популярные треки", style: TextStyle(color: Colors.white));
    }

    return Column(
      children: _popularTracks.take(10).map((track) => _buildPlaylistItem(track)).toList(),
    );
  }

  Widget _buildPlaylistItem(Track track) {
    return GestureDetector(
      onTap: () {
        context.read<PlayerProvider>().loadPlaylist([track]);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                track.thumbnailUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 60, height: 60, color: Colors.grey[800],
                  child: const Icon(Icons.music_note, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.author,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
