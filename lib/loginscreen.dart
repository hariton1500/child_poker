import 'dart:convert';
import 'dart:io';

//import 'package:childpoker/gamecomm.dart';
//import 'package:childpoker/gamepage.dart';
import 'package:childpoker/main_.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
//import 'package:web_socket_channel/status.dart' as status;


class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  
  static final TextEditingController _name = new TextEditingController();
  String playerName = '';
  List<dynamic> playersList = <dynamic>[], gamesList = [];
  Map<String, String> playersInGames = {};
  IOWebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    print('Start login screen...');
    ///
    /// Ask to be notified when messages related to the game
    /// are sent by the server
    ///
    //gamecomm.addListener(_onGameDataReceived);
  }
  @override
  Widget build(BuildContext context) {
    return new SafeArea(
      bottom: false,
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: new Text('UNO: classic'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              playerName == '' ? _buildJoin() : _buildlobby(),
              //Text('List of players:'),
              //_playersList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildlobby() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          Text('Список игроков:', style: TextStyle(fontSize: 25),),
          Divider(),
          _listPlayers(),
          Divider(),
          gamesList.isNotEmpty ? Text('Список игр:', style: TextStyle(fontSize: 25),) : Container(),
          gamesList.isNotEmpty ? _listGames() : Container(),
          RaisedButton(
            onPressed: _onCreateGameButtonPressed,
            color: Colors.red,
            child: Text(gamesList.contains(playerName) ? 'Удалить игру' : 'Создать игру'),
          ),
        ]
      ),
    );
  }

  Widget _listGames() {
    print(gamesList);
    return ListView.builder(
      shrinkWrap: true,
      itemCount: gamesList.length,
      itemBuilder: (context, index){
        return GestureDetector(
          onTap: _onGameTapped(gamesList[index]),
          child: ListTile(
            leading: Icon(Icons.play_circle_filled),
            title: Text(gamesList[index]),
            subtitle: Text(playersInGames.containsKey(gamesList[index]) ? playersInGames.values.toString() : ''),
            //onTap: _onGameTapped(gamesList[index]),
            enabled: playerName != gamesList[index],
            selected: true,
          )
        );
      },
    );
  }

  _onGameTapped(String name) {
    print('$playerName enter $name');
    channel.sink.add(jsonEncode({'type' : 'enterGame', 'gameName' : name, 'who' : playerName}));    
  }

  _onCreateGameButtonPressed() {
    channel.sink.add(jsonEncode({'type' : gamesList.contains(playerName) ? 'deleteGame' : 'createGame', 'name' : playerName}));
  }

  Widget _listPlayers() {
    print(playersList);
    return ListView.builder(
      shrinkWrap: true,
      itemCount: playersList.length,
      itemBuilder: (context, index){
        return ListTile(
          leading: Icon(Icons.person),
          title: Text(playersList[index]),
        );
      },
    );
  }

  Widget _buildJoin() {
    return new Container(
      padding: const EdgeInsets.all(16.0),
      child: new Column(
        children: <Widget>[
          TextField(
            controller: _name,
            keyboardType: TextInputType.text,
            decoration: new InputDecoration(
              hintText: 'Enter your name',
              contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(32.0),
              ),
              icon: const Icon(Icons.person),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              onPressed: _onGameJoin,
              child: new Text('Войти...'),
            ),
          ),
        ],
      ),
    );
  }

  void _onGameJoin() {
    //print(_name.text);
    String serverAddress = '193.106.162.117';
    if (_name.text.isNotEmpty) {
      channel = IOWebSocketChannel.connect("ws://$serverAddress:4040", pingInterval: Duration(seconds: 2));
      channel.stream.listen(handleMsg);
      channel.sink.add(jsonEncode({'type' : 'addPlayer', 'name' : _name.text, 'from' : Platform.localHostname}));// _name.text);
    }
  }

  void handleMsg(data) {
    print('recieved: $data');
    var msg = jsonDecode(data);
    switch (msg['type']) {
      case 'answer':
        if (msg['msgTo'] == Platform.localHostname) {
          if (msg['result'] == 'ok') {
            print('OK: ${msg['mess']}');
            setState(() {
              playerName = _name.text;
            });
          } else {
            print('Ошибка регистрации: ${msg['mess']}');
          }
        }
        break;
      case 'playersListUpdate':
        setState(() {
          playersList = msg['playersList'];
        });
        break;
      case 'gamesListUpdate':
        setState(() {
          gamesList = msg['gamesList'];
        });
        break;
      case 'playersInGamesUpdate':
        setState(() {
          playersInGames = msg['playersInGames'];
        });
        break;
      case 'startNewGame':
        Navigator.push(context, new MaterialPageRoute(
          builder: (BuildContext context)
                      => MyHomePage(),
        ));
        break;
      default:
    }
  }

}