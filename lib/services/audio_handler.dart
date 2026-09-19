import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:home_widget/home_widget.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'youtube_api_service.dart';
import '../models/track.dart';

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();
  final _youtubeApi = YoutubeApiService();
  
  List<Track> _queue = [];
  int _currentIndex = -1;

  MyAudioHandler() {
    _player.playbackEventStream.listen((event) {
      _broadcastState(event);
    });
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        skipToNext();
      }
    });
  }

  Future<void> loadPlaylist(List<Track> tracks, int startIndex) async {
    _queue = tracks;
    _currentIndex = startIndex;
    
    final mediaItems = tracks.map((t) => MediaItem(
      id: t.id,
      title: t.title,
      artist: t.author,
      artUri: Uri.parse(t.thumbnailUrl),
    )).toList();
    
    queue.add(mediaItems);
    await skipToQueueItem(startIndex);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_currentIndex < _queue.length - 1) {
      await skipToQueueItem(_currentIndex + 1);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_currentIndex > 0) {
      await skipToQueueItem(_currentIndex - 1);
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _queue.length) return;
    
    _currentIndex = index;
    final track = _queue[index];
    
    mediaItem.add(queue.value[index]);
    
    final streamUrl = await _youtubeApi.getAudioStreamUrl(track.id);
    if (streamUrl != null) {
      await _player.setUrl(streamUrl);
      play();
    } else {
      print('Failed to get stream url for \${track.id}, skipping to next...');
      Future.delayed(const Duration(seconds: 1), () => skipToNext());
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode == AudioServiceShuffleMode.all;
    await _player.setShuffleModeEnabled(enabled);
    if (enabled) {
      await _player.shuffle();
    }
  }

  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _currentIndex,
    ));

    _updateWidget();
  }

  Future<void> _updateWidget() async {
    final item = mediaItem.value;
    if (item != null) {
      await HomeWidget.saveWidgetData('title', item.title);
      await HomeWidget.saveWidgetData('artist', item.artist ?? 'Unknown Artist');
      await HomeWidget.saveWidgetData('isPlaying', _player.playing);
      
      // Download art to local file for the widget
      if (item.artUri != null) {
        try {
          final response = await http.get(item.artUri!);
          if (response.statusCode == 200) {
            final tempDir = await getTemporaryDirectory();
            final file = File('\${tempDir.path}/widget_art.jpg');
            await file.writeAsBytes(response.bodyBytes);
            await HomeWidget.saveWidgetData('artUri', file.path);
          }
        } catch (e) {
          print('Failed to download widget art: $e');
        }
      }
      
      await HomeWidget.updateWidget(name: 'MusicWidgetProvider');
    }
  }
}
