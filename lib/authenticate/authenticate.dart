import 'package:childbridge/authenticate/register.dart';
import 'package:childbridge/authenticate/sign_in.dart';
import 'package:flutter/widgets.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({Key? key}) : super(key: key);

  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool isShowSign = true;

  void toggle() {
    setState(() {
      isShowSign = !isShowSign;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isShowSign
        ? LoginPageFB(
            toggle: toggle,
          )
        : Register(
            toggle: toggle,
          );
  }
}
