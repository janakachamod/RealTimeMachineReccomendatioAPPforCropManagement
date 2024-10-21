import 'package:flutter/material.dart';
import 'signin.dart';
import 'register.dart';

class Authenicate extends StatefulWidget {
  const Authenicate({super.key});

  @override
  State<Authenicate> createState() => _AuthenicateState();
}

class _AuthenicateState extends State<Authenicate> {
  bool signinpage = true;

  void switchPages() {
    setState(() {
      signinpage = !signinpage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return signinpage
        ? SignIn(
            toggle: switchPages,
          )
        : Register(
            toggle: switchPages,
          );
  }
}
