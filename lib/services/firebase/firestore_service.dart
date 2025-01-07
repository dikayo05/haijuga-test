import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _posts = FirebaseFirestore.instance.collection('posts');
  // Map<String, dynamic> _postsMap = {};

// create post
  Future<void> addPost(String userId, String caption, String media) {
    return _posts.add({
      'user_id': userId,
      'caption': caption,
      'media': media,
      'like': 0,
      'comment': 0,
      'share': 0,
      'created_at': DateTime.now(),
    });
  }

// read post
  Stream<QuerySnapshot> getPostsStream() {
    final postsStream =
        _posts.orderBy('created_at', descending: true).snapshots();
    return postsStream;
  }

// dari dokementasi
  Future<void> fetchData() async {
    await _posts.get().then((event) {
      for (var doc in event.docs) {
        // _postsMap['docId'] = doc.id;
        // print("${doc.id} => ${doc.data()}");
      }
    });
  }

  // update post
  Future<void> updatePost(String id, String caption) {
    return _posts.doc(id).update({'caption': caption});
  }

  // delete post
  Future<void> deletePost(String id) {
    return _posts.doc(id).delete();
  }
}
