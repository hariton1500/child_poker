import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:childbridge/gamepage.dart';
import 'package:childbridge/startpage.dart';
import 'package:flutter/material.dart';

class RoomPage extends StatefulWidget {
  @override
  _RoomPageState createState() => _RoomPageState();

  final String player;
  final StreamSubscription subscription;
  final Socket socket;
  final String role, gameName;
  final bool isContinue;
 
  RoomPage({
    Key key,
    this.player,
    this.subscription,
    this.socket,
    this.role,
    this.gameName,
    this.isContinue}): super(key: key);
}

class _RoomPageState extends State<RoomPage> {

  List<String> coPlayers = [];
  Map<String, int> scoreMap = {};
  bool dataIsReady, runStarted = false;
  final state = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    print('room:init');
    dataIsReady = false;
    widget.subscription.onData((data) {handleMsg(data);});
    //widget.socket.write(json.encode({'type' : 'enterGame', 'who' : widget.player, 'gameName' : widget.gameName}));
    if (!widget.isContinue) {
      widget.socket.write(json.encode({'type' : 'enterGame', 'who' : widget.player, 'gameName' : widget.gameName}));
      //coPlayers = [widget.player];
      //scoreMap[widget.player] = 0;
    } else {
      //widget.socket.write(json.encode({'type' : 'continueGame', 'name' : widget.player}));
      widget.socket.write(json.encode({'type' : 'continueGame', 'who' : widget.player, 'gameName' : widget.gameName}));
    }
    super.initState();
  }

  void leaveRoom() {
    print('${widget.role} pressed back button');
    if (widget.role == 'visitor') widget.socket.write(json.encode({'type' : 'leaveGame', 'who' : widget.player, 'gameName' : widget.gameName}));
    if (widget.role == 'owner') widget.socket.write(json.encode({'type' : 'deleteGame', 'name' : widget.player}));
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context){return StartPage(widget.player, widget.subscription, widget.socket);}));
  }

  handleMsg(List<int> data) {
    String _msg = utf8.decode(data);
    _msg.split('|-|').forEach((element) {
      print(element);
      if (element.isNotEmpty) {
        var msg = jsonDecode(element);
        print('recieved: $msg');
        switch (msg['type']) {
          case 'dataReadyOk':
            dataIsReady = true;
            widget.socket.write(json.encode({'type' : 'createGame', 'name' : widget.player}));
          break;
          case 'playersInGames':
            //'type' : 'playersInGames', 'players' : <list>
            setState(() {
              json.decode(msg['players']).forEach((_player) => coPlayers.add(_player.toString()));
              json.decode(msg['scores']).forEach((_player, _score) => scoreMap[_player] = int.parse(_score.toString()));
              print(coPlayers);
              print(scoreMap);
            });
          break;
          case 'playersInGamesUpdate':
            //'type' : 'playersInGamesUpdate', 'newPlayerInGame' : _botName, 'score' : '0'
            setState(() {
              //coPlayers = [];
              coPlayers.add(msg['playerName'].toString());
              scoreMap[coPlayers.last] = int.parse(msg['score']);
              print(coPlayers);
              print(scoreMap);
            });
          break;
          case 'playersInGamesDowndate':
            //'type' : 'playersInGamesDowndate', 'playerName' : ....
            setState(() {
              //coPlayers = [];
              coPlayers.remove(msg['playerName'].toString());
              scoreMap.remove(msg['playerName'].toString());
              print(coPlayers);
              print(scoreMap);
            });
          break;
          case 'gameDestroyed':
            //Navigator.pop(context);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context){return StartPage(widget.player, widget.subscription, widget.socket);}));
          break;
          case 'runGame':
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context){return GamePage(player: widget.player, subscription: widget.subscription, socket: widget.socket, gameName: msg['gameName']);}));
          break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('room:build');
    print('Players are: $coPlayers');
    return Scaffold(
      key: state,
      appBar: AppBar(
        title: Text(widget.player),
        elevation: 5,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Text('Ждем партнеров по игре:'),
            _buildList(),
          ]
        )
      ),
      bottomNavigationBar: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RaisedButton(
              onPressed: (coPlayers.length > 1 && widget.role == 'owner' && !runStarted) ? _onStartGamePressed : null,
              child: Text('Запуск игры'),
            ),
            RaisedButton(
              onPressed: (widget.role == 'owner' && coPlayers.length <= 3) ? _sendAddBot : null,
              child: Text('Добавить бота'),
            ),
            RaisedButton(
              onPressed: leaveRoom,
              child: Text('Назад'),
            )
          ],
        ),
      )
    );
  }

  Widget _buildList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: coPlayers.length,
      itemBuilder: (context, _index) {
        return ListTile(
          dense: true,
          //leading: Text(_index.toString()),
          title: Text(coPlayers[_index]),
          subtitle: Text('Штрафных очков: ${scoreMap[coPlayers[_index]]}'),
        );
      }
    );
  }

  void _onStartGamePressed() {
    print('Starting game: ${widget.player}');
    widget.socket.write(json.encode({'type' : 'runGame', 'gameName' : widget.player}));
    setState(() {
      runStarted = true;
    });
  }

  void _sendAddBot() {
    widget.socket.write(json.encode({'type' : 'addBot', 'gameName' : widget.player}));
  }
}