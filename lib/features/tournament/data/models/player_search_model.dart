import '../../domain/entities/player_search_result.dart';

class PlayerSearchModel {
  const PlayerSearchModel({
    required this.id,
    required this.name,
    this.username,
    required this.email,
  });

  final int id;
  final String name;
  final String? username;
  final String email;

  factory PlayerSearchModel.fromJson(Map<String, dynamic> json) =>
      PlayerSearchModel(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        username: json['username'] as String?,
        email: json['email'] as String,
      );

  PlayerSearchResult toEntity() => PlayerSearchResult(
        id: id,
        name: name,
        username: username,
        email: email,
      );
}
