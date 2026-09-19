import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/track.dart';

class YoutubeApiService {
  static const String _apiKey = 'AIzaSyCHdG4jqAOAL0sKx8dtc6HmY9CO1OUHI_4';
  final YoutubeExplode _ytExplode = YoutubeExplode();

  YoutubeApiService();

  Future<List<Track>> searchTracks(String query) async {
    try {
      // 1. Поиск видео
      final searchUrl = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=30&q=${Uri.encodeComponent(query)}&key=$_apiKey'
      );
      final searchResponse = await http.get(searchUrl).timeout(const Duration(seconds: 10));

      if (searchResponse.statusCode != 200) {
        print('YouTube Search API Error: ${searchResponse.body}');
        return [];
      }

      final searchData = json.decode(searchResponse.body);
      final items = searchData['items'] as List<dynamic>? ?? [];
      
      if (items.isEmpty) return [];

      // 2. Получаем videoId всех видео
      final videoIds = items.map((item) => item['id']['videoId'] as String).join(',');

      // 3. Запрашиваем детали видео (длительность)
      final detailsUrl = Uri.parse(
        'https://www.googleapis.com/youtube/v3/videos?part=contentDetails&id=$videoIds&key=$_apiKey'
      );
      final detailsResponse = await http.get(detailsUrl).timeout(const Duration(seconds: 10));
      
      if (detailsResponse.statusCode != 200) {
        print('YouTube Video API Error: ${detailsResponse.body}');
        return [];
      }
      
      final detailsData = json.decode(detailsResponse.body);
      final detailItems = detailsData['items'] as List<dynamic>? ?? [];
      
      Map<String, int> durations = {};
      for (var detail in detailItems) {
        final id = detail['id'] as String;
        final durationIso = detail['contentDetails']['duration'] as String;
        durations[id] = _parseDuration(durationIso) * 1000; // in milliseconds
      }

      // 4. Собираем треки
      List<Track> tracks = [];
      for (var item in items) {
        final videoId = item['id']['videoId'];
        final snippet = item['snippet'];
        
        if (snippet['liveBroadcastContent'] == 'none') {
          tracks.add(
            Track(
              id: videoId,
              title: snippet['title'] ?? 'Unknown Title',
              author: snippet['channelTitle'] ?? 'Unknown Author',
              thumbnailUrl: snippet['thumbnails']?['high']?['url'] ?? '',
              durationMs: durations[videoId] ?? 0,
            )
          );
        }
      }
      return tracks;
    } catch (e, stacktrace) {
      print('Error searching tracks via HTTP REST: $e');
      print(stacktrace);
      return [];
    }
  }

  // Парсинг длительности из формата PT1H2M3S
  static int _parseDuration(String duration) {
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(duration);
    if (match == null) return 0;

    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;

    return hours * 3600 + minutes * 60 + seconds;
  }

  Future<String?> getAudioStreamUrl(String videoId) async {
    try {
      var manifest = await _ytExplode.videos.streamsClient.getManifest(videoId);
      var audioStream = manifest.audioOnly.withHighestBitrate();
      return audioStream.url.toString();
    } catch (e) {
      print('Error getting audio stream: \$e');
      return null;
    }
  }
  
  Future<List<Track>> getRecommendations(List<String> genres) async {
    String query = genres.join(' OR ') + ' music playlist';
    return await searchTracks(query);
  }

  void dispose() {
    _ytExplode.close();
  }
}
