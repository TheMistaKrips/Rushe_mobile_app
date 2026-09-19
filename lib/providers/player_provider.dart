import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import '../services/audio_handler.dart';
import '../models/track.dart';

class PlayerProvider extends ChangeNotifier {
  final MyAudioHandler _audioHandler;

  PlayerProvider(this._audioHandler) {
    _audioHandler.playbackState.listen((state) {
      notifyListeners();
    });
    _audioHandler.mediaItem.listen((item) {
      notifyListeners();
    });
  }

  MyAudioHandler get audioHandler => _audioHandler;

  bool get isPlaying => _audioHandler.playbackState.value.playing;
  
  MediaItem? get currentMediaItem => _audioHandler.mediaItem.value;

  Duration get currentPosition => _audioHandler.playbackState.value.position;
  
  void play() => _audioHandler.play();
  void pause() => _audioHandler.pause();
  void seek(Duration position) => _audioHandler.seek(position);
  void skipToNext() => _audioHandler.skipToNext();
  void skipToPrevious() => _audioHandler.skipToPrevious();

  Future<void> loadPlaylist(List<Track> tracks, {int startIndex = 0}) async {
    await _audioHandler.loadPlaylist(tracks, startIndex);
  }

  void toggleShuffle(bool isShuffle) {
    _audioHandler.setShuffleMode(
      isShuffle ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none
    );
  }
}
