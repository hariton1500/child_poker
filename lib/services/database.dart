import 'package:childbridge/models/game.dart';
import 'package:childbridge/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  //collections
  final CollectionReference gamesCollection =
      FirebaseFirestore.instance.collection('games');

  Future<List<Game>> get gamesList async {
    var document = await gamesCollection.doc('games').get();
    var data = document.data();
    print('[get gamesList] $data');
    List<Game> games = [];
    return games;
  }
  
  Stream<List<Game>> get games {
    return gamesCollection.snapshots().map<List<Game>>(_gamesFromQuerySnapshot);
  }

  //games list from QuerySnapshot
  List<Game> _gamesFromQuerySnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      String? name, owner, status;
      List? gamers;
      try {
        name = doc.get('name');
        print('name: $name');  
      } catch (e) {
        print('name: $e');
      }
      try {
        owner = doc.get('owner');
        print('owner: $owner');  
      } catch (e) {
        print('owner: $e');
      }
      try {
        gamers = doc.get('gamers');
        print('gamers: $gamers');  
      } catch (e) {
        print('gamers: $e');
      }
      try {
        status = doc.get('status');
        print('status: $status');  
      } catch (e) {
        print('status: e');
      }
      return Game(
        name: name ?? '',
        owner: owner ?? '',
        status: status ?? '',
        gamers: []
      );//List.castFrom<Map, GameUser>(data['gamers'] ?? []));
    }).toList();
  }

  Future createGame({required String gameName, required GameUser gamer}) async {
    print('[createGame start]');
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
        });
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
