import 'dart:math';

import 'package:flutter/material.dart';

class Uno {
  List<String> humanPlayers = ['Player1', 'Player2'], compPlayers = [];
  List<String> mastList = ['П', 'Т', 'Б', 'Ч'];
  List<String> dostList = ['6', '7', '8', '9', '10', 'В', 'Д', 'К', 'Т'];
  int currentMovePlayer = 1, basePlayer = 0;
  Map<String, List<String>> cards = {};
  Uno() {
    cards['base'] = [];
    cards['heap'] = [];
    humanPlayers.forEach((player) => cards[player] = []);
    compPlayers.forEach((player) => cards[player] = []);
    mastList.forEach((mast) {
      dostList.forEach((dost) {
        cards['base'].add(dost + '-' + mast);
      });
    });
    print('Карты: $cards');
  }

  List<String> getPlayerCards() {
    print(cards[humanPlayers[currentMovePlayer]]);
    return cards[humanPlayers[currentMovePlayer]];
  }

  void rand(String owner) {
    List<String> tempBase = [];
    int _cardsCount = cards[owner].length;
    for (var i = 0; i < _cardsCount; i++) {
      int index = Random().nextInt(cards[owner].length);
      tempBase.add(cards[owner][index]);
      cards[owner].removeAt(index);
    }
    //cards[owner].clear();
    cards[owner] = tempBase;
    print('Карты: $cards');
  }

  void razdacha(int num) {
    for (var i = 0; i < num; i++) {
      humanPlayers.forEach((player) {
        cards[player].add(cards['base'].first);
        cards['base'].removeAt(0);
      });
    }
  }

  List<String> initMove() {
    List<String> _move = [];
    cards['heap'].add(cards['base'].first);
    print(cards['heap']);
    _move.add(cards['base'].first);
    cards['base'].removeAt(0);
    String _dost = cards['heap'].first.split('-')[0];
    bool _sameDostCards = false;
    cards[humanPlayers[currentMovePlayer]].forEach((card){
      if (card.startsWith(_dost)) _sameDostCards = true;
      }
    );
    if (_sameDostCards) {
      _move.addAll(letPlayerEndMoveWithSameDostCards(_dost));
      print('Ход: $_move');
    }
    else {
      print('Ход: $_move');
      print('Переход хода игроку: ${setNextPlayer()}');
    }
    return _move;
  }

  List<String> letPlayerEndMoveWithSameDostCards(String dost) {
    List<String> _move = [];
    List<int> variants = [];
    print('Можно добавить карты к текущему ходу (укажите цифры через запятую):');
    int _index = 0;
    cards[humanPlayers[currentMovePlayer]].forEach((card) {
      if (card.startsWith(dost)) {
        print('Выбор: [$_index] $card');
        variants.add(_index);
      }
      _index++;
    });
    //String input = stdin.readLineSync();
    //print(input);
    //input.split(',').forEach((str){_move.add(cards[currentMovePlayer][int.parse(str)]);});

    return _move;

  }

  void setMoveTo(int index) {
    currentMovePlayer = index;
  }

  String setNextPlayer() {
    int numberOfPlayers = humanPlayers.length + compPlayers.length;
    if (currentMovePlayer == numberOfPlayers) {
      currentMovePlayer = 0;
    } else {
      currentMovePlayer++;
    };
    return humanPlayers[currentMovePlayer];
  }

  void razdachaToCurrentPlayer(int num) {
    for (var i = 0; i < num; i++) {
      cards[currentMovePlayer].add(cards['base'].first);
      cards['base'].removeAt(0);
    }
  }
  void makeRuleOperation(List<String> moveCards) {
    List<String> _card;
    _card = cards['heap'].last.split('-');
    String _dost = _card[0];
    switch (_dost) {
      case '6': {
        razdachaToCurrentPlayer(2);
      }
      break;
      case '7': {
        razdachaToCurrentPlayer(1);
      }
      break;
      case '8': {
        setNextPlayer();
      }
    }
  }
}
class CardWidget extends StatelessWidget {
  const CardWidget({Key key, this.card, this.game, this.mode}) : super(key : key);

  final String card;
  final Uno game;
  final String mode;

  @override
  Widget build(BuildContext context) {
    String dost = card != '-' ? card.split('-')[0] : '';
    String mast = card != '-' ? game.mastList.indexOf(card.split('-')[1]).toString() : '';
    return Container(
      width: mode == 'drag' ? 50 : 60,
      height: mode == 'drag' ? 80 : 90,
      color: Colors.white,
      padding: EdgeInsets.all(5),
      child: Column(
        children: <Widget>[
          Flexible(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: mode == 'drag' ? null : Text('$dost')
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: mode == 'drag' ? null : Image(image: AssetImage('assets/mast$mast.png'))
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: mode == 'drag' ? null : Text('$dost')
                ),
              ]
            )
          ),
          Flexible(
            flex: 6,
            child: Center(
              child: card != '-' ? Image(image: AssetImage('assets/mast$mast.png')) : null
            )
          ),
          Flexible(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: mode == 'drag' ? null : Text('$dost')
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: mode == 'drag' ? null : Image(image: AssetImage('assets/mast$mast.png'))
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: mode == 'drag' ? null : Text('$dost')
                ),
              ]
            )
          ),
        ],
      ),
    );
  }
}