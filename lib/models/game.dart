//import 'package:childbridge/models/user.dart';

class Game {
  String name = '';
  String owner = '';
  //List<GameUser> gamers = [];
  String status = '';
  Game({required this.name, required this.owner, required this.status});

  Game.gamesFromJson(Map<String, dynamic> parsedJson) :
    name = parsedJson['name'],
    owner = parsedJson['owner'],
    status = parsedJson['status'];
    //gamers = parsedJson['gamers'];

  //List gamersFromJson(Map<String, dynamic> parsedJson) :    gamers = parsedJson['gamers'];

}
