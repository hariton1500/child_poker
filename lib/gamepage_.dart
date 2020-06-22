import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:childbridge/endofgame.dart';
import 'package:childbridge/unoclient.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'bridgehelpers.dart';

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
  String dragData = '', moverName = '', moveMode = '';
  bool isMyMove = false, isNoCardsToMove = false, isEndOfGame = false;
  int scoreOfGame = 0;
  Map<String, int> scoreMap = {};

  @override
  void initState() {
    print('game:init');
    widget.subscription.onData((data) {handleMsg(data);});
    print('1sending: ${{'type' : 'inGame', 'gameType' : 'getMyCardsAndInitMove', 'name' : widget.player, 'gameName' : widget.gameName}}');
    widget.socket.write(json.encode({'type' : 'inGame', 'gameType' : 'getMyCardsAndInitMove', 'name' : widget.player, 'gameName' : widget.gameName}));
    super.initState();
  }

  void handleMsg(List<int> data) {
    String _msg = utf8.decode(data);
    print('Full message is: $_msg');
    _msg.split('|-|').forEach((element) {
      print(element);
      if (element.isNotEmpty) {
        var msg = jsonDecode(element);
        print('recieved: $msg');
        switch (msg['type']) {
          case 'yourCards':
            game.myMove.clear();
            for (var _card in json.decode(msg['cards'])) {
              game.myCards.add(_card.toString());
            }
            break;
          case 'inGame':
            switch (msg['typeMove']) {
              case 'yourCardsAndInitMove':
                for (var _card in json.decode(msg['cards'])) {
                  game.myCards.add(_card.toString());
                }
                game.heapCards.add(msg['heap']);
                setState(() {
                  game.baseCardsLeft = json.decode(msg['base']);
                });
                Map<String, dynamic> _coPs = json.decode(msg['coPlayers']);
                _coPs.forEach((key, value) {
                  game.cardsCoPlayers[key] = value;
                  print('$key have $value cards');
                });
                print('2sending: ${{'type' : 'inGame', 'gameType' : 'whatNextFirst?', 'name' : widget.player, 'gameName' : widget.gameName}}');
                widget.socket.write(json.encode({'type' : 'inGame', 'gameType' : 'whatNextFirst?', 'name' : widget.player, 'gameName' : widget.gameName}));
                break;
              case 'youCanAddCards':
                game.dostLimit = msg['dost'];
                setState(() {
                  game.myMove = [game.heapCards.last];
                  isMyMove = true;
                  moveMode = 'addCardByDost';
                  moverName = widget.player;
                });
                break;
              case 'setMast':
                game.mastLimit = msg['mast'];
                setState(() {
                  game.myMove = [];
                  isMyMove = true;
                  moveMode = 'addCardByMast';
                  moverName = widget.player;
                  if (ChildBridge(game).checkForCardsToMove()) isNoCardsToMove = !true; else isNoCardsToMove = !false;
                  //if (game.myCards.any((element) => game.mastOf(element) != game.mastLimit || game.dostOf(element) != 'В')) isNoCardsToMove = true; else isNoCardsToMove = false;
                });
                break;
              case 'moverIs':
                setState(() {
                  if (msg['movePlayer'].toString() == widget.player) {
                    isMyMove = true;
                    moveMode = 'newCard';
                    print('My move now. Now it is: ${game.myMove}');
                    if (game.myMove.length == 0) {
                      print('myMove is empty. Clean dost limits.');
                      game.dostLimit = '';
                    }
                    //проверка на наличие карт для хода
                    if (ChildBridge(game).checkForCardsToMove()) {
                      print('I have cards to move');
                      isNoCardsToMove = false;
                    } else {
                      print('I need take cards from base');
                      setState(() {
                        isNoCardsToMove = true;
                      });
                    }
                  } else {
                    isMyMove = false;
                  }
                  moverName = msg['movePlayer'];
                  print('isMyMove: $isMyMove');
                  print('move Player is: $moverName');
                });
                break;
              case 'addCards':
                json.decode(msg['cards']).forEach((card) {
                  game.myCards.add(card.toString());
                });
                setState(() {isNoCardsToMove = !ChildBridge(game).checkForCardsToMove();});
                break;
              //{'type' : 'inGame', 'typeMove': 'addCardsToCoPlayer', 'name' : _to, 'cardsNumber' : _cardsNumber.toString()}
              case 'addCardsToCoPlayer':
                if (msg['name'] != widget.player) {
                  setState(() {
                    moverName = msg['name'];
                    //game.cardsCoPlayers[msg['name']] += int.parse(msg['cardsNumber']);
                    print('adding ${msg['cards']} to $moverName');
                    game.cardsCoPlayers[msg['name']].addAll(msg['cards']);
                  });
                }
                break;
              case 'playerPlacedCard':
                //{'type' : 'inGame', 'typeMove': 'playerPlacedCard', 'name' : _name, 'card' : _card}
                if (msg['name'] != widget.player) {
                  setState(() {
                    moverName = msg['name'];
                    game.heapCards.add(msg['card']);
                    //game.cardsCoPlayers[msg['name']] -= 1;
                    game.cardsCoPlayers[msg['name']].remove(msg['card']);
                  });
                }
                break;
              case 'winner':
                //{'type' : 'inGame', 'typeMove' : 'winner', 'winnerName' : _winner, 'scoreMap' : json.encode(scoreMap[_game.name])}
                if (msg['winnerName'] == widget.player) {
                  scoreOfGame = 0;
                  print(msg['scoreMap']);
                  Map<String, dynamic> _scoreMap = json.decode(msg['scoreMap']);
                  _scoreMap.forEach((String _player, dynamic _int) {
                    print('$_player: $_int');
                    scoreMap[_player] = int.parse(_int.toString());
                  });
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context){return EndOfGamePage(player: widget.player, subscription: widget.subscription, socket: widget.socket, winner: msg['winnerName'], gameName: widget.gameName, score: scoreOfGame, scoreMap: scoreMap);}));
                } else {
                  print(msg['scoreMap']);
                  Map<String, dynamic> _scoreMap = json.decode(msg['scoreMap']);
                  _scoreMap.forEach((String _player, dynamic _int) {
                    print('$_player: $_int');
                    if (_player == widget.player) scoreOfGame = int.parse(_int.toString());
                  });
                  //scoreOfGame = int.parse(msg['scoreMap'][widget.player].toString());
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context){return EndOfGamePage(player: widget.player, subscription: widget.subscription, socket: widget.socket, winner: msg['winnerName'], gameName: widget.gameName, score: scoreOfGame, scoreMap: scoreMap);}));
                }
                break;
              default:
            }
          break;
        }
      }
    });
  }

  Future<bool> _canExit() async{
    return true;
  }

  @override
  Widget build(BuildContext context) {
    print('game:build');
    return WillPopScope(
      onWillPop: _canExit,
      child: Scaffold(
        key: state,
        bottomSheet: FlatButton(
          //color: Colors.blue,
          //padding: EdgeInsetsGeometry.lerp(a, b, t),
          textColor: Colors.green,
          onPressed: isMyMove && game.myMove.isNotEmpty ? () {
            print('My move is: ${game.myMove}');
            print('End of My move. Clean limits before Valet check');
            game.dostLimit = '';
            game.mastLimit = '';
            if (game.dostOf(game.myMove.last) == 'В') {
              var dialog = CupertinoAlertDialog(
                title: Text('Выберите масть'),
                actions: [
                  GestureDetector(
                    child: Container(
                      child: Image(image: AssetImage('assets/mast0.png')),
                      width: 60,
                      height: 60,
                    ),
                    onTap: () => Navigator.pop(context, 'П')
                  ),
                  GestureDetector(
                    child: Container(
                      child: Image(image: AssetImage('assets/mast1.png')),
                      width: 60,
                      height: 60,
                    ),
                    onTap: () => Navigator.pop(context, 'Т')
                  ),
                  GestureDetector(
                    child: Container(
                      child: Image(image: AssetImage('assets/mast2.png')),
                      width: 60,
                      height: 60,
                    ),
                    onTap: () => Navigator.pop(context, 'Б')
                  ),
                  GestureDetector(
                    child: Container(
                      child: Image(image: AssetImage('assets/mast3.png')),
                      width: 60,
                      height: 60,
                    ),
                    onTap: () => Navigator.pop(context, 'Ч')
                  ),
                ],
              );
              showCupertinoDialog(
                context: context,
                builder: (_) => dialog
              ).then((value) {
                print(value);
                print('3sending: ${{'type' : 'inGame', 'gameType' : 'playerMove', 'gameName' : widget.gameName, 'move' : game.myMove, 'mast' : value}}');
                widget.socket.write(json.encode({'type' : 'inGame', 'gameType' : 'playerMove', 'gameName' : widget.gameName, 'move' : json.encode(game.myMove), 'mast' : value}));
                setState(() {
                  game.mastLimit = value;
                  isMyMove = false;
                  game.myMove.clear();
                  isNoCardsToMove = false;
                });
                game.mastLimit = '';
              });
            } else {
              print('4sending: ${{'type' : 'inGame', 'gameType' : 'playerMove', 'gameName' : widget.gameName, 'move' : game.myMove, 'mast' : game.mastLimit}}');
              widget.socket.write(json.encode({'type' : 'inGame', 'gameType' : 'playerMove', 'gameName' : widget.gameName, 'move' : json.encode(game.myMove), 'mast' : game.mastLimit}));
              setState(() {
                isMyMove = false;
                game.myMove.clear();
                game.mastLimit = '';
                isNoCardsToMove = false;
              });
            }
          } : null,
          child: Text('Завершить ход')
        ),
        backgroundColor: Colors.lightBlue[300],
        appBar: AppBar(
          //leading: Icon(Icons.filter_center_focus),
          title: Text(widget.player),
          elevation: 5,
          centerTitle: true,
          backgroundColor: isMyMove ? Colors.green : Colors.red,
        ),
        body: Column(
          children: <Widget>[
            Flexible(
              flex: 3,
              //fit: FlexFit.tight,
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: _listCoPlayers(),
                ),
              ),
            ),
            Flexible(
              flex: 3,
              fit: FlexFit.tight,
              child: Container(
                alignment: Alignment.center,
                child: Wrap(
                  spacing: 10,
                  children: <Widget>[
                    game.mastLimit.isNotEmpty ?
                    Container(
                      //alignment: Alignment.center,
                      width: 60,
                      height: 60,
                      child: Image(image: AssetImage('assets/mast${game.mastList.indexOf(game.mastLimit)}.png'),),
                    ) : Container(width: 1, height: 1,),
                    DragTarget<String>(
                      onWillAccept: (card){
                        switch (moveMode) {
                          case 'addCardByDost':
                            return (game.dostOf(card) == game.dostLimit);
                            break;
                          case 'addCardByMast':
                            return (game.mastOf(card) == game.mastLimit || game.dostOf(card) == 'В');
                          default:
                            return (game.dostOf(card) == game.dostOf(game.heapCards.last) || game.mastOf(card) == game.mastOf(game.heapCards.last) || game.dostOf(card) == 'В');
                        }
                      },
                      onAccept: (String card){
                        setState(() {
                          game.myMove.add(card);
                          game.heapCards.add(card);
                          print('8sending...');
                          widget.socket.write(json.encode({'type' : 'inGame', 'gameType' : 'addHeap', 'heap' : game.heapCards.last, 'name' : widget.player, 'gameName' : widget.gameName}));
                          game.myCards.remove(card);
                          moveMode = 'addCardByDost';
                          game.dostLimit = game.dostOf(game.heapCards.last);
                          game.mastLimit = '';
                          if (!ChildBridge(game).checkForCardsToMove()) {
                            print('Ending move by auto');
                            game.mastLimit = '';
                            game.dostLimit = '';
                            if (game.dostOf(game.myMove.last) == 'В') {
                              var dialog = CupertinoAlertDialog(
                                title: Text('Выберите масть'),
                                actions: [
                                  GestureDetector(
                                    child: Container(
                                      child: Image(image: AssetImage('assets/mast0.png')),
                                      width: 60,
                                      height: 60,
                                    ),
                                    onTap: () => Navigator.pop(context, 'П')
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      child: Image(image: AssetImage('assets/mast1.png')),
                                      width: 60,
                                      height: 60,
                                    ),
                                    onTap: () => Navigator.pop(context, 'Т')
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      child: Image(image: AssetImage('assets/mast2.png')),
                                      width: 60,
                                      height: 60,
                                    ),
                                    onTap: () => Navigator.pop(context, 'Б')
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      child: Image(image: AssetImage('assets/mast3.png')),
                                      width: 60,
                                      height: 60,
                                    ),
                                    onTap: () => Navigator.pop(context, 'Ч')
                                  ),
                                ],
                              );
                              showCupertinoDialog(
                                context: context,
                                builder: (_) => dialog
                              ).then((value) {
                                print(value);
                                print('5sending: ${{'type' : 'inGame', 'gameType' : 'playerMove', 'gameName' : widget.gameName, 'move' : game.myMove, 'mast' : value}}');
                                widget.socket.write(json.encode({'type' : 'inGame', 'gameType' : 'playerMove', 'gameName' : widget.gameName, 'move' : json.encode(game.myMove), 'mast' : value}));
                                setState(() {
                                  game.mastLimit = value;
                                  isMyMove = false;
                                  game.myMove.clear();
                                  isNoCardsToMove = false;
                                });
                                game.mastLimit = '';
                              });
                            } else {
                              print('6sending: ${{'type' : 'inGame', 'gameType' : 'playerMove', 'gameName' : widget.gameName, 'move' : game.myMove, 'mast' : game.mastLimit}}');
                              widget.socket.write(json.encode({'type' : 'inGame', 'gameType' : 'playerMove', 'gameName' : widget.gameName, 'move' : json.encode(game.myMove), 'mast' : game.mastLimit}));
                              setState(() {
                                isMyMove = false;
                                game.myMove.clear();
                                game.mastLimit = '';
                                isNoCardsToMove = false;
                              });
                            }
                          }
                        });
                      },
                      builder: (context, candidates, rejects) {
                        if (candidates.isNotEmpty) return ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          child: Container(
                            width: 60,
                            height: 90,
                            color: Colors.green,
                            child: null,//Image(image: AssetImage('assets/back.png')),
                          )
                        );
                        if (rejects.isNotEmpty) return ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          child: Container(
                            width: 60,
                            height: 90,
                            color: Colors.red,
                            child: null,//Image(image: AssetImage('assets/back.png')),
                          )
                        );
                        return ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          child: CardWidget(
                            card: game.heapCards.isNotEmpty ? game.heapCards.last : '-',
                            game: game,
                            mode: 'target',
                          )
                        );
                      }
                    ),
                    GestureDetector(
                      onTap: isNoCardsToMove ? () {
                        print('7sending: ${{'type' : 'inGame', 'gameType' : 'takeCardFromBase', 'name' : widget.player, 'gameName' : widget.gameName}}');
                        widget.socket.write(json.encode({'type' : 'inGame', 'gameType' : 'takeCardFromBase', 'name' : widget.player, 'gameName' : widget.gameName}));
                        } : null,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        child: Container(
                          width: 60,
                          height: 90,
                          color: !isNoCardsToMove ? Colors.black54 : Colors.green,
                        ),//Image(image: AssetImage('assets/back.png')),
                      ),
                    ),
                  ]
                ),
              ),
            ),
            Flexible(
              flex: 4,
              //fit: FlexFit.tight,
              child: Container(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: listPlayerCardsWidgets(),
                )
              ),
            ),
          ]
        ),
      )
    );
  }

  List<Widget> _listCoPlayers() {
    List<Widget> _list = [];
    game.cardsCoPlayers.forEach((name, leftCards) {
      _list.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(name + (moverName == name ? ' (Ходит...)' : '')),
            Wrap(
              spacing: 10,
              children: _hiddenCards(leftCards.length)
            )
          ]
        )
      );
    });
    return _list;
  }

  List<Widget> _hiddenCards(int count) {
    List<Widget> _list = [];
    for (var i = 0; i < count; i++) {
      _list.add(
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          child: Container(
            width: 20,
            height: 30,
            color: Colors.black54,
            child: null,//Image(image: AssetImage('assets/back.png')),
          ),
        )
      );
    }
    return _list;
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
            child: isMyMove ?
              Draggable<String>(
                data: card,
                child: CardWidget(card: card, game: game),
                feedback: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  child: CardWidget(card: card, game: game, mode: 'drag')
                ),
                childWhenDragging: null,
              ) :
              CardWidget(card: card, game: game)
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