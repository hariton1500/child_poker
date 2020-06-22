import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:childbridge/unoclient.dart';
import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {

  final Socket socket;
  final String player, gameName;
  final StreamSubscription subscription;

  GamePage({
    Key key,
    this.player,
    this.subscription,
    this.socket,
    this.gameName
    }): super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  
  bool dataIsReady;
  final state = GlobalKey<ScaffoldState>();
  Uno game = Uno();
  Map<String, Color> cardColors = {};
  List<String> selectedCards = [];
  double cardWidth = 60;
  String dragData = '';

  @override
  void initState() {
    print('game:init');
    widget.subscription.onData((data) {handleMsg(data);});
    widget.socket.write(json.encode({'type' : 'inGame', 'gameType' : 'getMyCardsAndInitMove', 'name' : widget.player, 'gameName' : widget.gameName}));
    super.initState();
  }

  void handleMsg(List<int> data) {
    var msg = jsonDecode(utf8.decode(data));
    print('recieved: $msg');
    switch (msg['type']) {
      case 'yourCards':
        for (var _card in json.decode(msg['cards'])) {
          game.myCards.add(_card.toString());
        }
      break;
      case 'yourCardsAndInitMove':
        for (var _card in json.decode(msg['cards'])) {
          game.myCards.add(_card.toString());
        }
        game.heapCards.add(msg['heap']);
        setState(() {
          game.baseCardsLeft = json.decode(msg['base']);
        });
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('game:build');
    return Scaffold(
      backgroundColor: Colors.lightBlue[300],
      body: Container(
        child: Row(
          children: <Widget>[
            Flexible(
              flex: 6,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    direction: Axis.vertical,
                    spacing: 10,
                    runSpacing: 10,
                    children: listPlayerCardsWidgets(),
                  ),
                )
              )
            ),
            Flexible(
              flex: 4,
              child: Column(
                children: <Widget>[
                  Container(
                    child: _listCoPlayers(),
                  ),
                  Wrap(
                    spacing: 10,
                    children: <Widget> [
                      DragTarget<String>(
                        onWillAccept: (value){dragData = value;return true;},
                        onAccept: (String value){
                          setState(() {
                            game.heapCards.add(value);
                            game.myCards.remove(value);
                          });
                        },
                        builder: (context, candidates, rejects) {
                          return candidates.length > 0
                            ? ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                child: CardWidget(
                                  card: dragData,
                                  game: game,
                                  mode: 'heap',
                                )
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                child: CardWidget(
                                  card: game.heapCards.isNotEmpty ? game.heapCards.last : '-',
                                  game: game,
                                  mode: 'target',
                                )
                              )
                            ;
                        }
                      ),
                      game.baseCardsLeft > 0 ?
                        ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          child: GestureDetector(
                            onTap: (){
                              setState(() {
                                //game.cards[game.humanPlayers[game.currentMovePlayer]].add(game.cards['base'].first);
                                game.baseCardsLeft -= 1;
                              });
                            },
                            child: Container(
                              width: 60,
                              height: 90,
                              color: Colors.black54,
                              child: null,//Image(image: AssetImage('assets/back.png')),
                            ),
                          )
                        ) : Container(),
                    ]
                  )
                ]
              )
            )
          ],
        )
      )
    );
  }

  Widget _listCoPlayers() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: game.cardsCoPlayers.entries.length,
      itemBuilder: (BuildContext context, index) {
        return ListTile(
          leading: Text(game.cardsCoPlayers.keys.elementAt(index)),
          title: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            child: Center(
              child: Text(game.cardsCoPlayers.values.elementAt(index).toString())
            ),
          ),
        );
      }      
    );
  }

  List<Widget> listPlayerCardsWidgets() {
    List<String> _cards = game.myCards..sort();
    List<Widget> _list = [];
    _cards.forEach(
      (card) {
        //cardColors[card] = Colors.lightBlue[100];
        _list.add(
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            child: Draggable<String>(
              data: card,
              child: CardWidget(
                card: card,
                game: game,
              ),
              feedback: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                child: CardWidget(
                  card: card,
                  game: game,
                  mode: 'drag',
                )
              ),
              childWhenDragging: null,
            )
          )
        );
      }
    );
    return _list;
  }

  Widget getDost(String card) {
    return Text(card.split('-')[0]);
  }
  Widget getMast(String card) {
    return Text(card.split('-')[1]);
  }
}