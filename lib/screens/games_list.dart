import 'package:childbridge/models/game.dart';
import 'package:childbridge/models/user.dart';
import 'package:childbridge/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GamesList extends StatefulWidget {
  const GamesList({Key? key, required this.gameUser}) : super(key: key);
  final GameUser gameUser;

  @override
  _GamesListState createState() => _GamesListState();
}

class _GamesListState extends State<GamesList> {
  @override
  Widget build(BuildContext context) {
    final gamesList = Provider.of<List<Game>>(context);
    print('[GamesList]');
    //gamesList.forEach((game) {print('${game.name}: ${game.owner} status: ${game.status}');});
    List<Game> gamesToShow = List.from(gamesList.where((element) => element.status == 'created'));
    print(gamesToShow);
    return ListView.builder(
      itemCount: gamesToShow.length,
      itemBuilder: (context, index) {
        return ListTile(
            leading: Text(gamesToShow[index].gamers.length.toString()),
            title: Text(gamesToShow[index].name),
            subtitle: Column(
              children: List.generate(gamesToShow[index].gamers.length, (i) => Text(gamesToShow[index].gamers[i].name)),
            ),
            onTap:() {
              DatabaseService().enterToGame(gameName: gamesToShow[index].name, gamer: widget.gameUser);
            },
          );
      },
    );
  }
}
