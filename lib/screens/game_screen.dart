import 'package:childbridge/models/game.dart';
import 'package:childbridge/models/user.dart';
import 'package:flutter/material.dart';
class GameScreen extends StatefulWidget {
  const GameScreen({ Key? key, required this.game, required this.gameUser }) : super(key: key);
  final Game game;
  final GameUser gameUser;

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}