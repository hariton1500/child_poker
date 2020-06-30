import 'dart:async';
import 'dart:io';
import 'package:childbridge/room.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class EndOfGamePage extends StatefulWidget {
  @override
  _EndOfGamePageState createState() => _EndOfGamePageState();

  final String player;
  final StreamSubscription subscription;
  final Socket socket;
  final String gameName, winner;
  final int score;
  final Map<String, int> scoreMap;
 
  EndOfGamePage({
    Key key,
    this.player,
    this.subscription,
    this.socket,
    this.winner,
    this.gameName,
    this.score,
    this.scoreMap}): super(key: key);
}

class _EndOfGamePageState extends State<EndOfGamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.player),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(widget.player == widget.winner ? 'ПОБЕДА!!!' : 'ПРОИГРЫШ!', style: TextStyle(fontSize: 30),),
            widget.player == widget.winner ? _scoreTable() : Container(),
            Text(widget.player == widget.winner ? '' : 'Получено ${widget.score} штрафных очков'),
            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0)
              ),
              color: Colors.green,
              child: Text('Продолжить...'),
              onPressed: () {Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => RoomPage(player: widget.player, subscription: widget.subscription, socket: widget.socket, role: widget.player == widget.gameName ? 'owner' : 'visitor', gameName: widget.gameName, isContinue: true)));}
            )
          ]
        )
      ),
    );
  }

  Widget _scoreTable() {
    return ListView.builder(
      itemCount: widget.scoreMap.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return widget.scoreMap.keys.elementAt(index) != widget.winner ? Center(child: Text('${widget.scoreMap.keys.elementAt(index)}: ${widget.scoreMap.values.elementAt(index)}')) : Container();
      }
    );
  }

}
