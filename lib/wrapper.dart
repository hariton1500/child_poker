import 'package:childbridge/authenticate/authenticate.dart';
//import 'package:childbridge/authenticate/sign_in.dart';
//import 'package:childbridge/startpage.dart';
import 'package:childbridge/startscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    print('[wrapper] $user');
    if (user == null)
      return Authenticate();
    else {
      String playerName = '???';
      return StartScreen(); //StartPage(playerName, null, null);
    }
  }
}
