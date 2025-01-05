import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeModel {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final TextEditingController captionController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  List<Map<String, dynamic>> posts = [];
  DocumentSnapshot? lastDocument;
  bool isLoading = false;
  String mediaUrl = '';

  XFile? image;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);
    image = pickedImage;
  }

  Future<void> fetchData() async {
    lastDocument = null;
    posts.clear();

    if (isLoading) return;
    isLoading = true;

    QuerySnapshot querySnapshot;
    if (lastDocument == null) {
      querySnapshot = await db
          .collection("posts")
          .orderBy('created_at', descending: true)
          .limit(10)
          .get();
    } else {
      querySnapshot = await db
          .collection("posts")
          .orderBy('created_at', descending: true)
          .startAfterDocument(lastDocument!)
          .limit(10)
          .get();
    }

    if (querySnapshot.docs.isNotEmpty) {
      lastDocument = querySnapshot.docs.last;
      posts.insertAll(
          0,
          querySnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList());
    }

    isLoading = false;
  }

  Future<void> uploadPost() async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/dwxuluzp6/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'haijuga-app'
      ..files.add(await http.MultipartFile.fromPath('file', image!.path));
    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);
      mediaUrl = jsonMap['url'];
    }

    final post = <String, dynamic>{
      "user_id": "dfkj3kjsdf9",
      "caption": captionController.text,
      "media": mediaUrl,
      "created_at": DateTime.now()
    };
    db.collection("posts").add(post);
  }

  Future<void> editPost(String postId, String newCaption) async {
    await db.collection("posts").doc(postId).update({"caption": newCaption});
    fetchData();
  }

  Future<void> deletePost(String postId, String mediaUrl) async {
    await db.collection("posts").doc(postId).delete();

    final url = Uri.parse('https://api.cloudinary.com/v1_1/dwxuluzp6/delete_by_token');
    final request = http.MultipartRequest('POST', url)
      ..fields['token'] = mediaUrl;
    await request.send();

    fetchData();
  }

  Future<void> showPostDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Post Status'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void dispose() {
    captionController.dispose();
    scrollController.dispose();
  }
}
