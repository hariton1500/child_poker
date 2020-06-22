import 'unoclient.dart';

class ChildBridge {
  final Uno game;

  ChildBridge(this.game);

  bool checkForCardsToMove() {
    print('Check for cards to move');
    bool _answer = false;
    if (game.mastLimit.isNotEmpty) {
      print('mode is Mast Limit ${game.mastLimit}');
      game.myCards.forEach((_card) {
        if (game.mastOf(_card) == game.mastLimit) {print('card $_card is accaptable'); _answer = true;}
        if (game.dostOf(_card) == 'В') {print('card $_card is accaptable'); _answer = true;}
      });
    }
    if (game.dostLimit.isNotEmpty) {
      print('mode is Dost Limit ${game.dostLimit}');
      game.myCards.forEach((_card) {
        if (game.dostOf(_card) == game.dostLimit) {print('card $_card is accaptable'); _answer = true;}
        //if (game.dostOf(_card) == 'В') {print('card $_card is accaptable'); _answer = true;}
      });
    }
    if (game.dostLimit.isEmpty && game.mastLimit.isEmpty) {
      print('mode is No Limit. Heap is ${game.heapCards.last}');
      game.myCards.forEach((_card) {
        if (game.dostOf(_card) == game.dostOf(game.heapCards.last)) {print('card $_card is accaptable'); _answer = true;}
        if (game.mastOf(_card) == game.mastOf(game.heapCards.last)) {print('card $_card is accaptable'); _answer = true;}
        if (game.dostOf(_card) == 'В' && game.mastOf(_card) != game.mastOf(game.heapCards.last)) {print('card $_card is accaptable'); _answer = true;}
      });
    }
    print('Answer is : $_answer');
    return _answer;
  }

}

