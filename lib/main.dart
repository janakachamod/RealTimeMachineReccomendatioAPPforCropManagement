import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:pepperdisesesidentification/Ml Model.dart'; // Import your existing ML model page
import 'package:pepperdisesesidentification/models/usermodel.dart';
import 'package:pepperdisesesidentification/services/auth.dart'; // Import AuthService
import 'package:provider/provider.dart'; // Import Provider for state management
import 'package:pepperdisesesidentification/screens/wrapper.dart';
import 'package:pepperdisesesidentification/mongodb.dart'; // Import Wrapper screen

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter bindings are initialized
  await Firebase.initializeApp();
  await MongoDatabase
      .connect(); // Corrected 'MonngoDatabase' to 'MongoDatabase'
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel?>.value(
      value:
          AuthService().user, // Assuming AuthService has a stream of UserModel
      initialData: null,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const Wrapper(),
        debugShowCheckedModeBanner: false, // This line removes the debug banner
      ),
    );
  }
}
