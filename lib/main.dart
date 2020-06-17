import 'package:childbridge/authorize.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Детский бридж',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage('', null, null),
    );
  }
}
