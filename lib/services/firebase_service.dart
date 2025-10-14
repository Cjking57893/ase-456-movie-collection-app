import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static User? get currentUser => auth.currentUser;
  static bool get isSignedIn => currentUser != null;

  static CollectionReference get usersCollection =>
      firestore.collection('users');
  static CollectionReference get moviesCollection =>
      firestore.collection('movies');
  static Future<bool> testConnection() async {
    try {
      await firestore.enableNetwork();
      return true;
    } catch (e) {
      return false;
    }
  }
}
