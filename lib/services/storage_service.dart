import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/track.dart';
import '../models/playlist.dart';
import '../models/user_profile.dart';

class StorageService {
  static const String _userBox = 'userProfile';
  static const String _likesBox = 'likedTracks';
  static const String _playlistsBox = 'playlists';

  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);

    
    Hive.registerAdapter(TrackAdapter());
    Hive.registerAdapter(PlaylistAdapter());
    Hive.registerAdapter(UserProfileAdapter());

    await Hive.openBox<UserProfile>(_userBox);
    await Hive.openBox<Track>(_likesBox);
    await Hive.openBox<Playlist>(_playlistsBox);
  }

  UserProfile? getUserProfile() {
    final box = Hive.box<UserProfile>(_userBox);
    return box.get('profile');
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final box = Hive.box<UserProfile>(_userBox);
    await box.put('profile', profile);
  }
  
  Future<void> clearAll() async {
    await Hive.box<UserProfile>(_userBox).clear();
    await Hive.box<Track>(_likesBox).clear();
    await Hive.box<Playlist>(_playlistsBox).clear();
  }

  List<Track> getLikedTracks() {
    final box = Hive.box<Track>(_likesBox);
    return box.values.toList();
  }

  Future<void> toggleLike(Track track) async {
    final box = Hive.box<Track>(_likesBox);
    if (box.containsKey(track.id)) {
      await box.delete(track.id);
    } else {
      await box.put(track.id, track);
    }
  }

  bool isLiked(String id) {
    return Hive.box<Track>(_likesBox).containsKey(id);
  }
  
  List<Playlist> getPlaylists() {
    return Hive.box<Playlist>(_playlistsBox).values.toList();
  }
  
  Future<void> createPlaylist(Playlist playlist) async {
    final box = Hive.box<Playlist>(_playlistsBox);
    await box.put(playlist.id, playlist);
  }
  
  Future<void> updatePlaylist(Playlist playlist) async {
    final box = Hive.box<Playlist>(_playlistsBox);
    await box.put(playlist.id, playlist);
  }
  
  Future<void> deletePlaylist(String id) async {
    final box = Hive.box<Playlist>(_playlistsBox);
    await box.delete(id);
  }
}
