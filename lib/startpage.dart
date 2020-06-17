import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:childbridge/authorize.dart';
import 'package:childbridge/gamelistpage.dart';
import 'package:childbridge/room.dart';
import 'package:childbridge/unoclient.dart';
import 'package:flutter/material.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
  final String playerName;
  final StreamSubscription subscription;
  final Socket socket;
  StartPage(this.playerName, this.subscription, this.socket);
}

class _StartPageState extends State<StartPage> {

  @override
  void initState() {
    print('game:init');
    widget.subscription.onData((data) {handleMsg(data);});
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    print('start:build');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playerName),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Center(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: Uno().rules.length,
              itemBuilder: (context, index) {
                return Text(Uno().rules[index]);
              },
            )
          )
        )
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: _onFindGame,
              child: Text('Найти игру')
            ),
            RaisedButton(
              onPressed: _onCreateGame,
              child: Text('Создать игру')
            ),
          ]
        )
      ),
      bottomNavigationBar: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('Назад'),
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => LoginPage(widget.playerName, widget.subscription, widget.socket)))
            )
          ]
        )
      ),
    );
  }

  _onCreateGame() {
    widget.socket.write(json.encode({'type' : 'createGame', 'name' : widget.playerName}));
  }

  _onFindGame() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => GamesListPage(player: widget.playerName, subscription: widget.subscription, socket: widget.socket)));
  }

  void handleMsg(List<int> data) {
    String _msg = utf8.decode(data);
    print('Full message is: $_msg');
    _msg.split('|-|').forEach((element) {
      print(element);
      if (element.isNotEmpty) {
        var msg = jsonDecode(element);
        print('decoded msg: $msg');
        if (msg['type'] == 'roomCreated') {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => RoomPage(player: widget.playerName, subscription: widget.subscription, socket: widget.socket, role: 'owner', gameName: widget.playerName, isContinue: false)));
        }
      }
    });
  }

}