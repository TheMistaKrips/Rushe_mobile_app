import 'package:hive/hive.dart';

part 'track.g.dart';

@HiveType(typeId: 0)
class Track extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String author;

  @HiveField(3)
  final String thumbnailUrl;

  @HiveField(4)
  final int durationMs;

  Track({
    required this.id,
    required this.title,
    required this.author,
    required this.thumbnailUrl,
    required this.durationMs,
  });

  Duration get duration => Duration(milliseconds: durationMs);

  factory Track.fromMap(Map<String, dynamic> map) {
    return Track(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      thumbnailUrl: map['thumbnailUrl'],
      durationMs: map['durationMs'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'thumbnailUrl': thumbnailUrl,
      'durationMs': durationMs,
    };
  }
}
