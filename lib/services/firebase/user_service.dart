import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final _users = FirebaseFirestore.instance.collection('users');

// create user
  Future<void> add(String uid, String userName, String email) {
    return _users.doc(uid).set({
      'user_id': uid,
      'user_name': userName,
      'email': email,
      'porfile_picture': 'https://console.cloudinary.com/pm/c-cc816cdb2e22be567c096f44abde39/media-explorer/haijuga-media?assetId=103b88c89b2a7ef8c2ce42bb713cbe0cc',
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
