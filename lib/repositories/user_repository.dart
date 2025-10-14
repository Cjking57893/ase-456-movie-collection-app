import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

abstract class UserRepository {
  Future<void> createUser(User user);
  Future<User?> getUser(String userId);
  Future<void> updateUser(User user);
  Future<void> deleteUser(String userId);
}

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;
  static const String _collectionName = 'users';

  FirestoreUserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createUser(User user) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(user.id)
          .set(user.toMap());
    } on FirebaseException catch (e) {
      throw Exception('Could not create user profile: ${e.message}');
    } catch (e) {
      throw Exception('Could not create user profile');
    }
  }

  @override
  Future<User?> getUser(String userId) async {
    final doc = await _firestore.collection(_collectionName).doc(userId).get();

    if (doc.exists) {
      return User.fromMap(doc.data()!);
    }
    return null;
  }

  @override
  Future<void> updateUser(User user) async {
    await _firestore
        .collection(_collectionName)
        .doc(user.id)
        .update(user.toMap());
  }

  @override
  Future<void> deleteUser(String userId) async {
    await _firestore.collection(_collectionName).doc(userId).delete();
  }
}
