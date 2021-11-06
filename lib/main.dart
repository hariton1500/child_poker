import 'dart:ffi';

import 'package:childbridge/models/user.dart';
import 'package:childbridge/services/auth.dart';
import 'package:childbridge/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

GameUser gameUser = GameUser(name: '', owner: '');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<GameUser>.value(
      value: AuthService().user,
      initialData: gameUser,
      child: MaterialApp(
          title: 'Детский бридж',
          //theme: ThemeData(primarySwatch: Colors.blue,),
          debugShowCheckedModeBanner: false,
          home: Wrapper() //LoginPage('', null, null),
          ),
    );
  }
}
