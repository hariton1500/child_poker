import 'package:childbridge/models/game.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  //collections
  final CollectionReference gamesCollection =
      FirebaseFirestore.instance.collection('games');

  Stream<List<Game>> get games {
    return gamesCollection.snapshots().map(_gamesFromQuerySnapshot);
  }

  //games list from QuerySnapshot
  List<Game> _gamesFromQuerySnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      //print(doc.get('name') ?? 'no name');
      //print(doc.get('owner'));
      return Game(name: doc.get('name') ?? '', owner: doc.get('owner') ?? '');
    }).toList();
  }

  Future createGame({required String gameName, required String owner}) async {
    return await gamesCollection
        .doc(gameName)
        .set({'name': gameName, 'owner': owner});
  }
}
