import 'dart:convert';

import 'package:childbridge/models/game.dart';
import 'package:childbridge/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  //collections
  final CollectionReference gamesCollection =
      FirebaseFirestore.instance.collection('games');
  final _db = FirebaseFirestore.instance;

  Future<List<Game>> get gamesList async {
    var document = await gamesCollection.doc('games').get();
    var data = document.data();
    print('[get gamesList] $data');
    List<Game> games = [];
    return games;
  }
  
  Stream<List<Game>> getGames() {
    return _db.collection('games')
      .snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => Game.gamesFromJson(doc.data()))
      .toList()
    );
  }

  Future<DocumentReference<Map<String, dynamic>>> createGame({required String gameName, required GameUser gamer}) async {
    print('[createGame start]');
    return _db.collection('games').add({
          'name': gameName,
          'owner': gamer.uid,
          'gamers' : 0,
          'status': 'created'
        });
    /*
    return await gamesCollection
        .doc(gameName)
        .set({
          'name': gameName,
          'owner': gamer.uid,
          'gamers' : [{
            'name' : gamer.name,
            'uid': gamer.uid
          }],
          'status': 'created'
        });*/
  }

  Future<DocumentReference<Map<String, dynamic>>> addGameTable(DocumentReference documentReference) {
    return _db.collection(documentReference.toString()).add({});
  }

  Future enterToGame({required String gameName, required GameUser gamer}) async {
    var data = await gamesCollection.doc(gameName).get();
    print('[enterToGame]');
    List list = data.get('gamers');
    print('[List of gamers] $list');
    print(list[0]);
    List<GameUser> gamers = list.map<GameUser>((element) {return GameUser(name: element['name'], uid: element['uid']);}).toList();
    if (!gamers.contains(gamer)) gamers.add(gamer);
    print(data.get('gamers'));
    return await gamesCollection
      .doc(gameName)
      .update({'gamers': [{'name': gamer.name, 'uid': gamer.uid}]});
  }
}
