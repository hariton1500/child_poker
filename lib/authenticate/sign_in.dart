import 'package:childbridge/helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPageFB extends StatefulWidget {
  LoginPageFB({Key key, this.toggle}) : super(key: key);
  final Function toggle;

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
              onPressed: () {widget.toggle();},
              icon: Icon(Icons.person_add, color: Colors.white,),
              label: Text('Регистрация', style: TextStyle(color: Colors.white),))
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
                    dynamic result = await _auth.signInAnon(_name);
                    _auth.updateName(_name);
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
