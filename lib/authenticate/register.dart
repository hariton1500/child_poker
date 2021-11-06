import 'package:childbridge/services/auth.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  Register({Key? key, required this.toggle}) : super(key: key);
  final Function toggle;

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
        title: Text(
          'Вход в Детский бридж',
          textAlign: TextAlign.left,
        ),
        actions: [
          TextButton.icon(
              onPressed: () {
                widget.toggle();
              },
              icon: Icon(
                Icons.person,
                color: Colors.white,
              ),
              label: Text(
                'Вход',
                style: TextStyle(color: Colors.white),
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
                    dynamic result = await _auth.signInAnon(_name);
                    _auth.updateName(_name);
                    if (result == null)
                      print('error register anon');
                    else {
                      print('registered in by anon');
                      print(result);
                      //User _user = result;
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
