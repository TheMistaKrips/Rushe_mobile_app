import 'package:flutter_test/flutter_test.dart';
import 'package:rushe/services/youtube_api_service.dart';

void main() {
  test('YoutubeApiService searchTracks returns real results', () async {
    final apiService = YoutubeApiService();
    print('Testing YoutubeApiService searchTracks("kanye west")...');
    
    final tracks = await apiService.searchTracks('kanye west');
    print('Found \${tracks.length} tracks.');
    
    for (var track in tracks) {
      print('- \${track.title} (by \${track.author})');
    }
    
    expect(tracks.isNotEmpty, true, reason: 'Should return a list of tracks');
    
    if (tracks.isNotEmpty) {
      print('Fetching audio stream URL for the first track...');
      final url = await apiService.getAudioStreamUrl(tracks.first.id);
      print('Audio stream URL: \$url');
      expect(url, isNotNull, reason: 'Should return a valid audio stream URL');
    }
  });
}
