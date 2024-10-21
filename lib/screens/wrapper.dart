import 'package:pepperdisesesidentification/models/usermodel.dart';
import 'package:pepperdisesesidentification/screens/authenicate/authenicate.dart';
import 'package:pepperdisesesidentification/Ml Model.dart';
import 'package:flutter/material.dart';
import 'package:pepperdisesesidentification/screens/home/home.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    print(user);
    if (user == null) {
      return Authenicate();
    } else {
      return Home();
    }
    return Authenicate();
  }
}
