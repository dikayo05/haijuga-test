import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final _users = FirebaseFirestore.instance.collection('users');

// create user
  Future<void> add(String uid, String fullName, String email) {
    return _users.doc(uid).set({
      'user_id': uid,
      'full_name': fullName,
      'email': email,
      'date_of_birth': '',
      'gender': '',
      'profile_picture': '',
      'created_at': DateTime.now(),
    });
  }

// read user
  Stream<QuerySnapshot> getStream() {
    final usersStream =
        _users.orderBy('created_at', descending: true).snapshots();
    return usersStream;
  }

  // update user
  Future<void> update(String uid, String profilePicture) {
    return _users.doc(uid).update({'profile_picture': profilePicture});
  }

  // delete user
  Future<void> delete(String id) {
    return _users.doc(id).delete();
  }
}
