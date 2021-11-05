import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseService {
  final FirebaseStorage _database = FirebaseStorage.instance;

  Future updateData() async {
    try {} catch (e) {}
  }
}

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

  Stream<User> get user {
    return _auth.authStateChanges();
  }

  Future updateName (String displayName) async {
    try {
      _auth.currentUser.updateDisplayName(displayName);
    } catch (e) {
    }
  }

  Future signInAnon(String name) async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      result.user.updateDisplayName(name);
      User user = result.user;
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
