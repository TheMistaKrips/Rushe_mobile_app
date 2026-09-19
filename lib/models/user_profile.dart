import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 2)
class UserProfile extends HiveObject {
  @HiveField(0)
  final String nickname;

  @HiveField(1)
  final List<String> favoriteGenres;

  UserProfile({
    required this.nickname,
    required this.favoriteGenres,
  });
}
