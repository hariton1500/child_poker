class GameUser {
  late final String name;
  late final String uid;
  GameUser({required this.uid, required this.name});

  GameUser.fromJson(Map<String, dynamic> parsedJson) :
    name = parsedJson['name'],
    uid = parsedJson['uid'];
}
