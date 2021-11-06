import 'package:childbridge/models/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GamesList extends StatefulWidget {
  const GamesList({Key? key}) : super(key: key);

  @override
  _GamesListState createState() => _GamesListState();
}

class _GamesListState extends State<GamesList> {
  @override
  Widget build(BuildContext context) {
    final gamesList = Provider.of<List<Game>>(context);
    print('[GamesList]');
    gamesList.forEach((game) {
      print('${game.name}: ${game.owner}');
    });

    return ListView.builder(
      itemCount: gamesList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(gamesList[index].name),
        );
      },
    );
  }
}
