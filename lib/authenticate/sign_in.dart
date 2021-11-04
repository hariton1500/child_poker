import 'package:childbridge/helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPageFB extends StatefulWidget {
  const LoginPageFB({Key key}) : super(key: key);

  @override
  _LoginPageFBState createState() => _LoginPageFBState();
}

class _LoginPageFBState extends State<LoginPageFB> {
  final AuthService _auth = AuthService();
  String _name = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Вход в Детский бридж'),
        actions: [
          TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.person_add),
              label: Text('Регистрация'))
        ],
      ),
      body: Container(
        child: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Имя:'),
                  Container(
                    width: 200,
                    child: TextField(
                      keyboardType: TextInputType.name,
                      onChanged: (name) {
                        _name = name;
                      },
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                  onPressed: () async {
                    dynamic result = await _auth.signInAnon();
                    if (result == null)
                      print('error signing anon');
                    else {
                      print('signed in by anon');
                      print(result);
                      User _user = result;
                      //_user.displayName = _name;
                    }
                  },
                  child: Text('Enter...'))
            ],
          ),
        ),
      ),
    );
  }
}
