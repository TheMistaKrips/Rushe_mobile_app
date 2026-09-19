import 'package:googleapis/youtube/v3.dart' as yt;
import 'package:googleapis_auth/auth_io.dart';

void main() async {
  final _apiKey = 'AIzaSyCHdG4jqAOAL0sKx8dtc6HmY9CO1OUHI_4';
  final client = clientViaApiKey(_apiKey);
  final _youtubeApi = yt.YouTubeApi(client);

  try {
    final response = await _youtubeApi.search.list(
      ['snippet'],
      q: 'lofi',
      type: ['video'],
      videoCategoryId: '10',
      maxResults: 5,
    );
    print('Success: \${response.items?.length} items');
  } catch (e) {
    print('API Error: \$e');
  }
}
