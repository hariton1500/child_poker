import 'package:childbridge/main.dart';
import 'package:childbridge/models/game.dart';
import 'package:childbridge/models/user.dart';
import 'package:childbridge/screens/game_screen.dart';
import 'package:childbridge/screens/games_list.dart';
import 'package:childbridge/services/auth.dart';
import 'package:childbridge/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<GameUser>(context);
    //final games = Provider.of<List<Game>>(context);
    return StreamProvider<List<Game>>.value(
      catchError: (context, game) {
        print('[startscreen] catchError');
        return [];
      },
      initialData: [],
      value: DatabaseService().games,
      child: Scaffold(
        appBar: AppBar(
          title: Text(user.name),
          actions: [
            TextButton.icon(
                onPressed: () {
                  _auth.signOut();
                },
                icon: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
                label: Text(
                  'Выход',
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
        floatingActionButton: FloatingActionButton(
          //isExtended: true,
          child: Icon(Icons.games),
          onPressed: () async {
            var result = await DatabaseService().createGame(
                gameName: '${user.name}\'s game',
                gamer: user
            );
            print('[startscreen] $result');
            setState(() {
            });
            List<Game> games = await DatabaseService().gamesList;
            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => GameScreen(game: games.last, gameUser: gameUser)));
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: GamesList(gameUser: user),
      ),
    );
  }
}
