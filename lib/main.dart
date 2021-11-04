//import 'package:childbridge/authorize.dart';
import 'package:childbridge/authenticate/sign_in.dart';
import 'package:childbridge/helpers.dart';
import 'package:childbridge/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
          title: 'Детский бридж',
          //theme: ThemeData(primarySwatch: Colors.blue,),
          debugShowCheckedModeBanner: false,
          home: Wrapper() //LoginPage('', null, null),
          ),
    );
  }
}
