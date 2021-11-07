import 'package:childbridge/main.dart';
import 'package:childbridge/models/game.dart';
import 'package:childbridge/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class GameScreen extends StatefulWidget {
  GameScreen({ Key? key, required this.gameUser, required this.gameTableRef }) : super(key: key);
  final DocumentReference<Map<String, dynamic>> gameTableRef;
  //Game game = Game(name: '', owner: '', status: '');
  final GameUser gameUser;

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: [
            Text(widget.gameUser.uid),
            Text(widget.gameUser.name),
            Text(widget.gameTableRef.toString()),
          ]
        )
      ),
    );
  }
}