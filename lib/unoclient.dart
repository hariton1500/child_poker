import 'package:flutter/material.dart';

class Uno {
  List<String> mastList = ['П', 'Т', 'Б', 'Ч'];
  List<String> dostList = ['6', '7', '8', '9', '10', 'В', 'Д', 'К', 'Т'];
  int currentMovePlayer = 1, basePlayer = 0, baseCardsLeft;
  Map<String, List<String>> cardsCoPlayers = {};
  Map<String, int> scores;
  List<String> myCards, heapCards, myMove, baseCards;
  String dostLimit = '', mastLimit = '';
  final List<String> rules = [
    'Правила игры:',
    'Смысл этой игры в том, чтобы побыстрее избавиться от карт и набрать наименьшее количество очков, а проиграет тот, кто наберет больше 100 очков.',
    'Тот, кто наберет 95 очков обнуляет свой счет.',
    'Раздается по 5 карт.',
    'Ходит игрок после того участника, который раздавал карты, ходят по часовой стрелке.',
    'Одна карта выкладывается вверх лицом (от лица раздающего), на нее будут выкладываться остальные карты - по масти или по фигуре (например - пика к пике, валет к валету).',
    'Если у игрока на руках нет подходящей карты, он берет ее из колоды (разрешается добирать по одной карте).',
    'Тот игрок, перед которым положили на кон:', 
    '- 6 - берет две карты из колоды и пропускает ход;',
    '- 7 - берет одну карту из колоды и пропускает ход;',
    '- 8 - берет одну карту из колоды и ходит;',
    '- Туз - пропускает ход.',
    'Кто походил шестеркой делает еще один ход.',
    'За тем игроком, кто положил туз, следующий игрок пропускает ход.',
    'Если на руках Валет, он может быть положен на любую карту - любого номинала и масти. После чего игрок выбирает масть',
    'Если на Вальте заканчивается игра, игроки получают удвоенные очки.',
    'Как считать очки:',
    'номиналы карт: 6, 7, 8, 9 - имеют ноль очков.',
    '10, ДамаБ Король имеют по 10 очков',
    'Туз - 15',
    'Валет - 20'
  ];

  Uno() {
    myCards = [];
    myMove = [];
    heapCards = [];
    cardsCoPlayers = {};
    baseCardsLeft = 0;
    scores = {};
  }

  String dostOf(String card) {
    return card.split('-')[0];
  }

  String mastOf(String card) {
    return card.split('-')[1];
  }

}

class CardWidget extends StatelessWidget {
  const CardWidget({Key key, this.statePosition, this.card, this.game, this.mode, this.isNoCardsToMove}) : super(key : key);

  final String card;
  final Uno game;
  final String mode;
  final String statePosition;
  final bool isNoCardsToMove;

  @override
  Widget build(BuildContext context) {
    String dost = card != '-' ? card.split('-')[0] : '';
    String mast = card != '-' ? game.mastList.indexOf(card.split('-')[1]).toString() : '';
    return Container(
      width: (mode == 'drag' || game.myCards.length >=10) ? 50 : 60,
      height: (mode == 'drag' || game.myCards.length >=10) ? 80 : 90,
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

class CardBack extends StatelessWidget {
  final bool isSmall;
  final Color color;

  const CardBack({Key key, this.isSmall, this.color}) : super(key : key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.all(Radius.circular(5.0))
      ),
      height: !isSmall ? 90 : 30,
      width: !isSmall ? 60 : 20,
    );  
  }
}
