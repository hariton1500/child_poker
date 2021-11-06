import 'package:childbridge/authenticate/authenticate.dart';
import 'package:childbridge/models/user.dart';
import 'package:childbridge/screens/startscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<GameUser?>(context);
    print('[wrapper] uid:${user!.uid}, name:${user.name}');
    if (user.uid.isEmpty)
      return Authenticate();
    else {
      //String playerName = '???';
      return StartScreen(); //StartPage(playerName, null, null);
    }
  }
}
