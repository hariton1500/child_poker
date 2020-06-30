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
  //List<String> selectedCards = [];
  double cardWidth = 60;
  String dragData = '', moverName = '', moveMode = '', comment = '';
  bool isMyMove = false, isNoCardsToMove = false, isEndOfGame = false;
  int scoreOfGame = 0;
  Map<String, int> scoreMap = {};
  Size deviceSize;

  @override
  void initState() {
    print('game:init');
    super.initState();
    widget.subscription.onData((data) {handleMsg(data);});
    print('1sending: ${{'type' : 'inGame', 'gameType' : 'getMyCardsAndInitMove', 'name' : widget.player, 'gameName' : widget.gameName}}');
    Timer(Duration(seconds: 1), () => widget.socket.write(json.encode({'type' : 'inGame', 'gameType' : 'getMyCardsAndInitMove', 'name' : widget.player, 'gameName' : widget.gameName})));
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
                  print('$key: $value');
                  game.cardsCoPlayers[key] = [];
                  value.forEach((dynamic _card){
                    print(_card);
                    game.cardsCoPlayers[key].add(_card.toString());
                  });
                });
                print(game.cardsCoPlayers);
                setState(() {});
                print('2sending: ${{'type' : 'inGame', 'gameType' : 'whatNextFirst?', 'name' : widget.player, 'gameName' : widget.gameName}}');
                widget.socket.write(json.encode({'type' : 'inGame', 'gameType' : 'whatNextFirst?', 'name' : widget.player, 'gameName' : widget.gameName}));
                break;
              case 'youCanAddCards':
                print('commmmment!!!!!!!!!!!!!!!!!!!!!!');
                game.dostLimit = msg['dost'];
                setState(() {
                  comment = 'Можно добавить карты с достоинством: ${game.dostLimit}';
                  game.myMove = [game.heapCards.last];
                  isMyMove = true;
                  moveMode = 'addCardByDost';
                  moverName = widget.player;
                });
                comment = '';
                break;
              case 'setMast':
                game.mastLimit = msg['mast'];
                setState(() {
                  game.myMove = [];
                  isMyMove = true;
                  moveMode = 'addCardByMast';
                  moverName = widget.player;
                  if (ChildBridge(game).checkForCardsToMove()) isNoCardsToMove = false; else {
                    isNoCardsToMove = true;
                    print('7.1sending: ${{'type' : 'inGame', 'gameType' : 'takeCardFromBase', 'name' : widget.player, 'gameName' : widget.gameName}}');
                    widget.socket.write(json.encode({'type' : 'inGame', 'gameType' : 'takeCardFromBase', 'name' : widget.player, 'gameName' : widget.gameName}));
                  }
                });
                break;
              case 'moverIs':
                //if (!checkForWinner()) {
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
                        print('7.1sending: ${{'type' : 'inGame', 'gameType' : 'takeCardFromBase', 'name' : widget.player, 'gameName' : widget.gameName}}');
                        widget.socket.write(json.encode({'type' : 'inGame', 'gameType' : 'takeCardFromBase', 'name' : widget.player, 'gameName' : widget.gameName}));
                      }
                    } else {
                      isMyMove = false;
                    }
                    moverName = msg['movePlayer'];
                    print('isMyMove: $isMyMove');
                    print('move Player is: $moverName');
                  });
                //}
                break;
              case 'addCards':
                json.decode(msg['cards']).forEach((card) {
                  game.myCards.add(card.toString());
                });
                if (!ChildBridge(game).checkForCardsToMove()) {
                  //print('7.1sending: ${{'type' : 'inGame', 'gameType' : 'takeCardFromBase', 'name' : widget.player, 'gameName' : widget.gameName}}');
                  //widget.socket.write(json.encode({'type' : 'inGame', 'gameType' : 'takeCardFromBase', 'name' : widget.player, 'gameName' : widget.gameName}));
                }
                setState(() {isNoCardsToMove = !ChildBridge(game).checkForCardsToMove();});
                break;
              //{'type' : 'inGame', 'typeMove': 'addCardsToCoPlayer', 'name' : _to, 'cardsNumber' : _cardsNumber.toString()}
              case 'addCardsToCoPlayer':
                if (msg['name'] != widget.player) {
                  setState(() {
                    moverName = msg['name'];
                    //game.cardsCoPlayers[msg['name']] += int.parse(msg['cardsNumber']);
                    print('adding ${msg['cards']} to $moverName');
                    json.decode(msg['cards']).forEach((_card){
                      game.cardsCoPlayers[msg['name']].add(_card.toString());
                    });
                  });
                }
                break;
              case 'playerPlacedCard':
                //{'type' : 'inGame', 'typeMove': 'playerPlacedCard', 'name' : _name, 'card' : _card}
                if (msg['name'] != widget.player) {
                  moverName = msg['name'];
                  String _card = msg['card'];
                  game.baseCards.add(game.heapCards.last);
                  game.heapCards = [_card];
                  //game.heapCards.add(msg['card']);
                  //game.cardsCoPlayers[msg['name']] -= 1;
                  game.cardsCoPlayers[msg['name']].remove(_card);
                  //if (!checkForWinner() && game.cardsCoPlayers[moverName].length > 0) setState(() {});
                  setState(() {});
                  Timer(Duration(seconds:1), () => checkForWinner());
                  print(game.heapCards);
                }
                break;
              case 'winner_':
                //{'type' : 'inGame', 'typeMove' : 'winner', 'winnerName' : _winner, 'scoreMap' : json.encode(scoreMap[_game.name])}
                game.heapCards = [];
                game.myCards = [];
                game.cardsCoPlayers.forEach((player, cards) {
                  game.cardsCoPlayers[player] = [];
                });
                setState(() {});
                if (msg['winnerName'] == widget.player) {
                  scoreOfGame = 0;
                  print(msg['scoreMap']);
                  Map<String, dynamic> _scoreMap = json.decode(msg['scoreMap']);
                  _scoreMap.forEach((String _player, dynamic _int) {
                    print('$_player: $_int');
                    scoreMap[_player] = int.parse(_int.toString());
                  });
                  Timer(Duration(milliseconds: 1000), () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context){return EndOfGamePage(player: widget.player, subscription: widget.subscription, socket: widget.socket, winner: msg['winnerName'], gameName: widget.gameName, score: scoreOfGame, scoreMap: scoreMap);})));
                } else {
                  print(msg['scoreMap']);
                  Map<String, dynamic> _scoreMap = json.decode(msg['scoreMap']);
                  _scoreMap.forEach((String _player, dynamic _int) {
                    print('$_player: $_int');
                    if (_player == widget.player) scoreOfGame = int.parse(_int.toString());
                  });
                  //scoreOfGame = int.parse(msg['scoreMap'][widget.player].toString());
                  Timer(Duration(milliseconds: 1000), () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context){return EndOfGamePage(player: widget.player, subscription: widget.subscription, socket: widget.socket, winner: msg['winnerName'], gameName: widget.gameName, score: scoreOfGame, scoreMap: scoreMap);})));
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
    deviceSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: _canExit,
      child: Scaffold(
        key: state,
        floatingActionButton: RaisedButton(
          elevation: 3.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0)
          ),
          textColor: Colors.white,
          color: Colors.green,
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
                checkForWinner();
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
              checkForWinner();
            }
          } : null,
          child: Text('Завершить ход')
        ),
        backgroundColor: Colors.lightBlue[300],
        appBar: AppBar(
          title: Text('Ваше имя: ${widget.player}'),
          elevation: 0,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.help),
            onPressed: (){state.currentState.openDrawer();},
          ),
          centerTitle: true,
          backgroundColor: isMyMove ? Colors.green : Colors.red,
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
        body: SafeArea(
          child: Container(
            color: Colors.black,
            child: Stack(
              children: cardsWidgets(game)
            )
          )
        ),
      )
    );
  }

  String whereIsCard(String mast, String dost, Uno game) {
    //print('whereisCard $dost-$mast');
    //print('my: ${game.myCards}');
    //print('heap: ${game.heapCards}');
    //print('co: ${game.cardsCoPlayers}');
    String _pos = 'base';
    if (game.myCards.contains('$dost-$mast')) _pos = 'player';
    if (game.heapCards.contains('$dost-$mast')) _pos = 'heap';
    game.cardsCoPlayers.forEach((player, cards) {
      if (cards.contains('$dost-$mast')) _pos = 'coPlayer_$player';
    });
    game.cardsCoPlayers.forEach((key, value) {
      if (value.length == 0) print('$dost-$mast: $_pos');      
    });
    return _pos;
  }

  List<double> getPosition(String mast, String dost, Uno game) {
    //print('getPos of $dost-$mast');
    double baseCardPositionTop = deviceSize.height / 2 - 90, baseCardPositionLeft = deviceSize.width / 2 + 30;
    //колода
    List<double> _pos = [baseCardPositionTop, baseCardPositionLeft];
    //карты игрока
    int qInRow = game.myCards.length > 10 ? 6 : 5;
    int otstup = game.myCards.length > 10 ? 60 : 70;
    if (game.myCards.contains('$dost-$mast')) {
      _pos = [baseCardPositionTop + 120 + ((game.myCards.indexOf('$dost-$mast')) / qInRow).floor() * 100, 10.0 + game.myCards.indexOf('$dost-$mast') % qInRow * otstup];
    }
    //куча
    if (game.heapCards.contains('$dost-$mast')) _pos[1] -= 70;
    //противники
    game.cardsCoPlayers.forEach((player, cards) {
      if (cards.contains('$dost-$mast')) {
        _pos = [30 + game.cardsCoPlayers.keys.toList().indexOf(player) * 60.0, 10.0 + cards.indexOf('$dost-$mast') * 25];
      }
    });
    //print(_pos);
    return _pos;
  }
  
  List<Widget> cardsWidgets(Uno _game) {
    List<Widget> _listOfCards = [];
    game.baseCards = [];
    _game.mastList.forEach((_mast) {
      _game.dostList.forEach((_dost) {
        String _statePosition = whereIsCard(_mast, _dost, _game);
        switch (_statePosition) {
          case 'base':
            game.baseCards.add('$_dost-$_mast');
            _listOfCards.add(
              AnimatedPositioned(
                key: Key('$_dost-$_mast'),
                child: GestureDetector(
                  onTap: isNoCardsToMove ? () {
                    print('7sending: ${{'type' : 'inGame', 'gameType' : 'takeCardFromBase', 'name' : widget.player, 'gameName' : widget.gameName}}');
                    widget.socket.write(json.encode({'type' : 'inGame', 'gameType' : 'takeCardFromBase', 'name' : widget.player, 'gameName' : widget.gameName}));
                    } : null,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    child: Container(
                      width: 60,
                      height: 90,
                      color: isMyMove ? Colors.green : Colors.red,
                    ),//Image(image: AssetImage('assets/back.png')),
                  ),
                ),
                duration: Duration(milliseconds: 1000),
                curve: Curves.linearToEaseOut,
                top: getPosition(_mast, _dost, _game)[0],
                left: getPosition(_mast, _dost, _game)[1],
              )
            );
            break;
          case 'heap':
            _listOfCards.add(
              AnimatedPositioned(
                key: Key('$_dost-$_mast'),
                child: DragTarget<String>(
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
                      checkForWinner();
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
                            checkForWinner();
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
                          //checkForWinner();
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
                duration: Duration(milliseconds: 1000),
                curve: Curves.linearToEaseOut,
                top: getPosition(_mast, _dost, _game)[0],
                left: getPosition(_mast, _dost, _game)[1],
              )
            );
            break;
          case 'player':
            _listOfCards.add(
              AnimatedPositioned(
                key: Key('$_dost-$_mast'),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  child: isMyMove ?
                    Draggable<String>(
                      data: '$_dost-$_mast',
                      child: CardWidget(card: '$_dost-$_mast', game: game),
                      feedback: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        child: CardWidget(card: '$_dost-$_mast', game: game, mode: 'drag')
                      ),
                      childWhenDragging: null,
                    ) :
                    CardWidget(card: '$_dost-$_mast', game: game)
                ),
                duration: Duration(milliseconds: 500),
                top: getPosition(_mast, _dost, _game)[0],
                left: getPosition(_mast, _dost, _game)[1],
              )
            );
            break;
          default:
            _listOfCards.add(
              AnimatedPositioned(
                key: Key('$_dost-$_mast'),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  child: Container(
                    width: 20,
                    height: 30,
                    color: moverName != game.cardsCoPlayers.keys.firstWhere((player) => game.cardsCoPlayers[player].contains('$_dost-$_mast'))  ? Colors.red : Colors.green,
                    child: null,//Image(image: AssetImage('assets/back.png')),
                  ),
                ),
                duration: Duration(milliseconds: 1000),
                curve: Curves.linearToEaseOut,
                top: getPosition(_mast, _dost, _game)[0],
                left: getPosition(_mast, _dost, _game)[1],
              )
            );
        }
      });
    });
    //имена игроков
    game.cardsCoPlayers.forEach((player, cards) {
      if (cards.isNotEmpty) {
        _listOfCards.add(
          Positioned(
            top: getPosition(game.mastOf(cards.first), game.dostOf(cards.first), game)[0] - 20,
            left: 10.0,
            child: Text(player + (moverName == player ? ' (Ходит...)' : ''), style: TextStyle(color: Colors.white, fontSize: 16),)
          )
        );
      }
    });
    //масть
    if (game.mastLimit.isNotEmpty) _listOfCards.add(
      Positioned(
        top: getPosition(game.mastOf(game.heapCards.first), game.dostOf(game.heapCards.first), game)[0] + 15,
        left: getPosition(game.mastOf(game.heapCards.first), game.dostOf(game.heapCards.first), game)[1] - 70,
        child: Container(
          width: 60,
          height: 60,
          child: Image(image: AssetImage('assets/mast${game.mastList.indexOf(game.mastLimit)}.png'),),
        )
      )
    );
    //подсказка
    double baseCardPositionTop = deviceSize.height / 2 - 90;
    if (comment != '') _listOfCards.add(
      Positioned(
        top: baseCardPositionTop + 95,
        left: 10.0,
        child: Text(comment, style: TextStyle(color: Colors.white, fontSize: 15, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),)
      )
    );
    return _listOfCards;
  }

  bool checkForWinner() {
    print('checkForWinner:');
    print(game.myCards);
    print(game.cardsCoPlayers);
    if (game.myCards.length == 0) {
      scoreOfGame = 0;
      game.getScores();
      Timer(Duration(milliseconds: 1000), () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context){return EndOfGamePage(player: widget.player, subscription: widget.subscription, socket: widget.socket, winner: widget.player, gameName: widget.gameName, score: scoreOfGame, scoreMap: game.scores);})));
      return true;
    }
    game.cardsCoPlayers.forEach((_player, _cards) {
      if (_cards.length == 0) {
        scoreOfGame = game.getMyScore();
        Timer(Duration(milliseconds: 1000), () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context){return EndOfGamePage(player: widget.player, subscription: widget.subscription, socket: widget.socket, winner: _player, gameName: widget.gameName, score: scoreOfGame, scoreMap: scoreMap);})));
        return true;
      }
    });
    return false;
  }
}
