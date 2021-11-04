import 'package:childbridge/helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({Key key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
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
              icon: Icon(
                Icons.person_add,
                color: Colors.white,
              ),
              label: Text(
                'Вход',
              ))
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
                      print('error register anon');
                    else {
                      print('registered in by anon');
                      print(result);
                      User _user = result;
                      //_user.displayName = _name;
                    }
                  },
                  child: Text('Регистрация'))
            ],
          ),
        ),
      ),
    );
  }
}
