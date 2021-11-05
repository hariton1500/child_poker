import 'package:childbridge/helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key key}) : super(key: key);

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    //user.updateDisplayName('anon');

    return Scaffold(
      appBar: AppBar(
        title: Text(user.displayName ?? user.uid),
        actions: [
          TextButton.icon(
              onPressed: () {
                _auth.signOut();
              },
              icon: Icon(Icons.person, color: Colors.white,),
              label: Text('Выход', style: TextStyle(color: Colors.white),))
        ],
      ),
      body: Container(),
    );
  }
}
