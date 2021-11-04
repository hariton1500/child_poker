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
    return Scaffold(
      appBar: AppBar(
        title: Text('Детский бридж'),
        actions: [
          TextButton.icon(
              onPressed: () {
                _auth.signOut();
              },
              icon: Icon(Icons.person_remove),
              label: Text('Выход'))
        ],
      ),
      body: Container(),
    );
  }
}
