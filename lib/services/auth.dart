import 'package:pepperdisesesidentification/models/usermodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
// Import the ProfileModel

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref(); // Updated to use ref() method

  // Create UserModel based on Firebase User
  UserModel? _userFromFirebaseUser(User? user) {
    return user != null ? UserModel(uid: user.uid) : null;
  }

  // Auth change user stream
  Stream<UserModel?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign out
  // Simple Sign out function
  Future<void> signOut() async {
    try {
      await _auth.signOut(); // Sign out the user from Firebase Authentication
    } catch (e) {
      print('Error during sign out: $e'); // Log the error if any
    }
  }

  // Sign in anonymously
  Future<UserModel?> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Fetch user profile data

  // Method to set online status to true when user logs in
  Future<void> setOnlineStatus(bool status) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _dbRef
            .child('users')
            .child(user.uid)
            .update({'onlineStatus': status});
      } catch (e) {
        print("Error setting online status: $e");
      }
    }
  }
}
