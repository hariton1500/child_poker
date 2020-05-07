import 'package:childpoker/uno.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
         visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'UNO: classic'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Uno game;
  Map<String, Color> cardColors = {};
  List<String> selectedCards = [];
  double cardWidth = 60;
  String dragData = '';

  @override
  void initState() {
    super.initState();
    game = Uno();
    print('Размешиваем колоду');
    game.rand('base');
    //print('Карты: ${game.cards}');
    print('Раздаем по 5 карт');
    game.razdacha(5);
    print('Карты: ${game.cards}');
    game.setMoveTo(0);
    game.initMove();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Colors.lightBlue[300],
      body: Container(
        child: Row(
          children: <Widget>[
            Flexible(
              flex: 6,
              child: Container(
                alignment: Alignment.centerLeft,
                //color: Colors.yellow,
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
              //fit: FlexFit.tight,
              flex: 4,
              child: Wrap(
                spacing: 10,
                //direction: Axis.vertical,
                //color: Colors.white,
                children: <Widget> [
                  DragTarget<String>(
                    onWillAccept: (value){dragData = value;return true;},
                    onAccept: (String value){
                      setState(() {
                        game.cards['heap'].add(value);
                        game.cards[game.humanPlayers[game.currentMovePlayer]].remove(value);
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
                              card: game.cards['heap'].isNotEmpty ? game.cards['heap'].last : '-',
                              game: game,
                              mode: 'target',
                            )
                          )
                        ;
                    }
                  ),
                  game.cards['base'].isNotEmpty ?
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            game.cards[game.humanPlayers[game.currentMovePlayer]].add(game.cards['base'].first);
                            game.cards['base'].removeAt(0);
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
            )
          ],
        )
      )
    );
  }

  List<Widget> listPlayerCardsWidgets() {
    List<String> _cards = game.getPlayerCards()..sort();
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
