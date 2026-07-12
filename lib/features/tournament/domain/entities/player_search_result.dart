import 'package:equatable/equatable.dart';

class PlayerSearchResult extends Equatable {
  const PlayerSearchResult({
    required this.id,
    required this.name,
    this.username,
    required this.email,
  });

  final int id;
  final String name;
  final String? username;
  final String email;

  @override
  List<Object?> get props => [id, name, username, email];
}
