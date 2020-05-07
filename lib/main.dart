import 'package:flutter/material.dart';
import 'loginscreen.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Детский покер',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new StartPage(),
    );
  }
}
