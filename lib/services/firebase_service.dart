import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  // Get Firebase Auth instance
  static FirebaseAuth get auth => FirebaseAuth.instance;
  
  // Get Firestore instance
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  
  // Get current user
  static User? get currentUser => auth.currentUser;
  
  // Check if user is signed in
  static bool get isSignedIn => currentUser != null;
  
  // Movies collection reference
  static CollectionReference get moviesCollection => 
      firestore.collection('movies');
  
  // Users collection reference  
  static CollectionReference get usersCollection =>
      firestore.collection('users');
      
  // Test Firebase connection
  static Future<bool> testConnection() async {
    try {
      // Try to access Firestore
      await firestore.enableNetwork();
      return true;
    } catch (e) {
      print('Firebase connection test failed: $e');
      return false;
    }
  }
}