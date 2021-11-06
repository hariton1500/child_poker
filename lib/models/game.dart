import 'package:childbridge/models/user.dart';

class Game {
  final String name;
  final String owner;
  List<GameUser> gamers = [];
  String status = '';
  Game({required this.name, required this.owner, required this.status, required this.gamers});

}
