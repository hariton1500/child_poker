import 'package:childbridge/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Stream<GameUser> get user {
    return _auth.authStateChanges().map((event) => _userFromUser(event!));
  }

  GameUser _userFromUser(User user) {
    return GameUser(name: user.displayName ?? '', owner: user.uid);
  }

  Future updateName(String displayName) async {
    try {
      _auth.currentUser!.updateDisplayName(displayName);
    } catch (e) {}
  }

  Future signInAnon(String name) async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      result.user!.updateDisplayName(name);
      User? user = result.user;
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
