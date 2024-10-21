import 'package:flutter/material.dart';
import 'package:pepperdisesesidentification/screens/home/home.dart';
import 'register.dart'; // Ensure the import path is correct
import '../../constants/colors.dart';
import '../../constants/styles.dart';
import '../../services/auth.dart';
import 'package:pepperdisesesidentification/Ml Model.dart';

class SignIn extends StatefulWidget {
  final VoidCallback toggle;

  const SignIn({super.key, required this.toggle});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String error = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBlack,
      appBar: AppBar(
        backgroundColor: bgBlack,
        elevation: 0.0,
        title: const Text("Sign In", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration:
                            TextInputDecoration.copyWith(hintText: "Email"),
                        style: TextStyle(color: Colors.white),
                        validator: (value) => value?.isEmpty == true
                            ? "Enter a valid email"
                            : null,
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration:
                            TextInputDecoration.copyWith(hintText: "Password"),
                        style: TextStyle(color: Colors.white),
                        obscureText: true,
                        validator: (value) => value!.length < 6
                            ? "Password must be at least 6 characters"
                            : null,
                        onChanged: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      if (error.isNotEmpty)
                        Text(error, style: TextStyle(color: Colors.red)),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? ",
                              style: TextStyle(color: Colors.white)),
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              widget.toggle(); // Correct usage of toggle
                            },
                            child: Text(
                              "REGISTER",
                              style: TextStyle(
                                  color: mainBlue, fontWeight: FontWeight.w600),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            dynamic result = await _auth
                                .signInWithEmailAndPassword(email, password);
                            if (result != null) {
                              // Navigate to Home screen on successful sign-in
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Home(),
                                ),
                              );
                            } else {
                              setState(() {
                                error = "Sign in failed. Please try again.";
                              });
                            }
                          }
                        },
                        child: Container(
                          height: 40,
                          width: 200,
                          decoration: BoxDecoration(
                            color: mainYellow,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(width: 2, color: mainYellow),
                          ),
                          child: Center(
                            child: Text(
                              "LOGIN",
                              style: TextStyle(
                                color: bgBlack,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
