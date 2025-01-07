import 'package:cloud_firestore/cloud_firestore.dart';

class MessageService {
  final _messages = FirebaseFirestore.instance.collection('messages');

// create message
  Future<void> addMessage(String userId, String message) {
    return _messages.add({
      'user_id': userId,
      'message': message,
      'created_at': DateTime.now(),
    });
  }
}
