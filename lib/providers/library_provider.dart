import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../models/track.dart';
import '../models/playlist.dart';
import '../models/user_profile.dart';

class LibraryProvider extends ChangeNotifier {
  final StorageService _storageService;

  LibraryProvider(this._storageService);
  
  UserProfile? get userProfile => _storageService.getUserProfile();
  
  Future<void> saveUserProfile(UserProfile profile) async {
    await _storageService.saveUserProfile(profile);
    notifyListeners();
  }

  List<Track> get likedTracks => _storageService.getLikedTracks();

  bool isLiked(String id) => _storageService.isLiked(id);

  Future<void> toggleLike(Track track) async {
    await _storageService.toggleLike(track);
    notifyListeners();
  }
  
  List<Playlist> get playlists => _storageService.getPlaylists();
  
  Future<void> createPlaylist(String name, String coverUrl) async {
    final newPlaylist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      coverUrl: coverUrl,
      tracks: [],
    );
    await _storageService.createPlaylist(newPlaylist);
    notifyListeners();
  }
  
  Future<void> addTrackToPlaylist(String playlistId, Track track) async {
    final playlists = _storageService.getPlaylists();
    final pIndex = playlists.indexWhere((p) => p.id == playlistId);
    if (pIndex != -1) {
      final playlist = playlists[pIndex];
      if (!playlist.tracks.any((t) => t.id == track.id)) {
        playlist.tracks.add(track);
        await _storageService.updatePlaylist(playlist);
        notifyListeners();
      }
    }
  }
  
  Future<void> deletePlaylist(String id) async {
    await _storageService.deletePlaylist(id);
    notifyListeners();
  }
  
  Future<void> clearAllData() async {
    await _storageService.clearAll();
    notifyListeners();
  }
}
