import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:childbridge/room.dart';
import 'package:childbridge/startpage.dart';
import 'package:flutter/material.dart';

class GamesListPage extends StatefulWidget {

  final Socket socket;
  final String player;
  final StreamSubscription subscription;

  GamesListPage({
    Key key,
    this.player,
    this.subscription,
    this.socket,
    }): super(key: key);

  @override
  _GamesListPageState createState() => _GamesListPageState();
}

class _GamesListPageState extends State<GamesListPage> {
  
  List<dynamic> games = [];
  bool dataIsReady, canTap;
  final state = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    print('gamelist:init');
    dataIsReady = false;
    canTap = false;
    widget.subscription.onData((data) {handleMsg(data);});
    widget.socket.write(json.encode({'type' : 'dataReady', 'from' : widget.player}));
    super.initState();
    Future.delayed(Duration(seconds: 5), (){
      if (!dataIsReady) {
        state.currentState.showSnackBar(SnackBar(content: Text('Ошибка связи с сервером. Перерегистрируйтесь в игре'),));
      }
    });
  }

  void onGameEnterPressed(int _index) {
    //widget.socket.write(json.encode({'type' : 'enterGame', 'who' : widget.player, 'gameName' : games[_index]}));
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => RoomPage(player: widget.player, subscription: widget.subscription, socket: widget.socket, role: 'visitor', gameName: games[_index], isContinue: false,)));
  }

  handleMsg(List<int> data) {
    String _msg = utf8.decode(data);
    var msg = jsonDecode(_msg.substring(0,_msg.length - 3));
    print('recieved: $msg');
    switch (msg['type']) {
      case 'dataReadyOk':
        dataIsReady = true;
        widget.socket.write(json.encode({'type' : 'getGamesList', 'name' : widget.player}));
      break;
      case 'gamesListUpdate':
        setState(() {
          games = json.decode(msg['gamesList']);
        });
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('gamelist:build');
    return Scaffold(
      key: state,
      appBar: AppBar(
        title: Text(widget.player),
        centerTitle: true,
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        left: true,
        right: true,
        child: Column(
          children: <Widget>[
            Text('Список игр:'),
            _listGames()
          ]
        )
      ),
      bottomNavigationBar: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('Назад'),
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context){return StartPage(widget.player, widget.subscription, widget.socket);}))//Navigator.pop(context)
            )
          ]
        )
      ),
    );
  }

  Widget _listGames() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: games.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 3.0,
          margin: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.games),
                title: Text(games[index]),
                //enabled: canTap ? true : false,
                onTap: () => onGameEnterPressed(index),
              )
            ]
          )
        );
      }
    );
  }
}