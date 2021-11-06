import 'package:childbridge/models/game.dart';
import 'package:childbridge/screens/games_list.dart';
import 'package:childbridge/services/auth.dart';
import 'package:childbridge/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final user = Provider.of<User>(context);
    //final games = Provider.of<Games>(context);
    //user.updateDisplayName('anon');

    return StreamProvider<List<Game>>.value(
      catchError: (context, game) {
        return [];
      },
      initialData: [],
      value: DatabaseService().games,
      child: Scaffold(
        appBar: AppBar(
          title: Text(user.displayName ?? user.uid),
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
          onPressed: () {
            setState(() {
              DatabaseService().createGame(
                  gameName:
                      '${user.displayName ?? user.uid.substring(1, 5)}s game',
                  owner: user.uid);
            });
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: GamesList(),
      ),
    );
  }
}
