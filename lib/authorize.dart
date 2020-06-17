import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:childbridge/startpage.dart';
import 'package:childbridge/unoclient.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
  final String serverAddress = '193.106.162.117';//'91.195.230.13';//
  final String _playerName;
  final StreamSubscription _subscription;
  final Socket _socket;
  LoginPage(this._playerName, this._subscription, this._socket);
}

class _LoginPageState extends State<LoginPage> {
  
  static final TextEditingController _name = new TextEditingController();
  String playerName = '';
  Socket socket;
  StreamSubscription subscription;
  final state = GlobalKey<ScaffoldState>();
  //final List<String> rules = Uno().rules;

  @override
  void initState() {
    print('authorize:init');
    playerName = widget._playerName;
    subscription = widget._subscription;
    socket = widget._socket;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('authorize:build');
    print('Current player is: $playerName');
    return Scaffold(
      key: state,
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
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.help),
          onPressed: (){state.currentState.openDrawer();},
        ),
        title: Text('Детский бридж'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _buildJoin(),
          ],
        ),
      ),
    );
  }

  Widget _buildJoin() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          TextField(
            controller: _name,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Ваше имя?',
              contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32.0),
              ),
              icon: const Icon(Icons.person),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(
                  onPressed: _onGameConnect,//_onGameJoin,
                  child: Text(widget._playerName.isEmpty ? 'Войти...' : 'Поменять имя...'),
                ),
                widget._playerName.isNotEmpty ?
                  RaisedButton(
                    onPressed: _stayOldName,
                    child: Text('Оставить ${widget._playerName}'),
                  ):
                  Container()
              ]
            )
          ),
        ],
      ),
    );
  }

  _stayOldName() {
    playerName = widget._playerName;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context){return StartPage(_name.text, subscription, socket);}));
  }

  _onGameConnect() async{
    if (_name.text.isNotEmpty) {
      playerName = _name.text.trim();
      Future<Socket> channel = Socket.connect(widget.serverAddress, 4040);
      channel.then((Socket stream) {
        print('Connected to: ${stream.remoteAddress.address}');
        socket = stream;
        subscription = stream.listen((event) {handleMsg(event, socket);});
        stream.write(json.encode({'type' : 'addPlayer', 'name' : playerName, 'from' : Platform.localHostname}));
      });
    }
  }
  void handleMsg(data, Socket socket) {
    //print('recieved raw: $data');
    String _msg = utf8.decode(data);
    var msg = jsonDecode(_msg.substring(0,_msg.length - 3));
    print('recieved: $msg');
    switch (msg['type']) {
      case 'answer':
        if (msg['result'] == 'ok') {
          print('setting playerName: ${_name.text}');
          playerName = _name.text.trim();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context){return StartPage(playerName, subscription, socket);}));
        } else {
          print('Ошибка регистрации: ${msg['mess']}');
          state.currentState.showSnackBar(SnackBar(content: Text('Ошибка регистрации: ${msg['mess']}'),));
        }
      break;
    }
  }
}