import 'package:hive/hive.dart';
import 'track.dart';

part 'playlist.g.dart';

@HiveType(typeId: 1)
class Playlist extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String coverUrl;

  @HiveField(3)
  final List<Track> tracks;

  Playlist({
    required this.id,
    required this.name,
    required this.coverUrl,
    required this.tracks,
  });
}
