import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firebase/post_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final PostService _postService = PostService();
  final _firestorePosts = FirebaseFirestore.instance.collection('posts');
  String? _mediaUrl = '';
  XFile? _image;
  final ScrollController _scrollController = ScrollController();
  List<DocumentSnapshot> _postsList = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _documentLimit = 5;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _getPosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future<void> _uploadImage() async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/dwxuluzp6/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'haijuga-app'
      ..files.add(await http.MultipartFile.fromPath('file', _image!.path));
    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);
      _mediaUrl = jsonMap['url'];
    }
  }

  Future<void> _getUserName(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc['user_name'];
  }

  Future<void> _getPosts() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    QuerySnapshot querySnapshot;
    if (_lastDocument == null) {
      querySnapshot = await _firestorePosts.orderBy('created_at', descending: true)
          .limit(_documentLimit)
          .get();
    } else {
      querySnapshot = await _firestorePosts.orderBy('created_at', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_documentLimit)
          .get();
    }

    if (querySnapshot.docs.length < _documentLimit) {
      _hasMore = false;
    }

    if (querySnapshot.docs.isNotEmpty) {
      _lastDocument = querySnapshot.docs.last;
      _postsList.addAll(querySnapshot.docs);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _getPosts();
    }
  }

  void _showEditDialog(
      String docId, String currentCaption, String currentMedia) {
    TextEditingController captionController =
        TextEditingController(text: currentCaption);
    TextEditingController mediaController =
        TextEditingController(text: currentMedia);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: captionController,
                decoration: InputDecoration(hintText: "Enter new caption"),
              ),
              _image == null
                  ? const Text('No image selected.')
                  : Image.file(width: 150, height: 150, File(_image!.path)),
              ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Pick Image from Gallery')),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                _postService.updatePost(
                    docId, captionController.text, _mediaUrl!);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget menuPopup(String docId, String currentCaption, String currentMedia,
      String postUserId) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        if (value == 'edit') {
          _showEditDialog(docId, currentCaption, currentMedia);
        } else if (value == 'delete') {
          _postService.deletePost(docId);
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          if (FirebaseAuth.instance.currentUser!.uid == postUserId)
            PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
          if (FirebaseAuth.instance.currentUser!.uid == postUserId)
            PopupMenuItem(
              value: 'delete',
              child: Text('Hapus'),
            ),
          PopupMenuItem(
            value: 'report',
            child: Text('Laporkan'),
          ),
        ];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _postsList.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _postsList.length) {
          return Center(child: CircularProgressIndicator());
        }
        DocumentSnapshot document = _postsList[index];
        String docId = document.id;
        Map<String, dynamic> post = document.data() as Map<String, dynamic>;
        return postCardWidget(post, docId);
      },
    );
  }

  Column postCardWidget(Map<String, dynamic> post, String docId) {
    return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10), // Add spacing between posts
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey), // Add border to the post card
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Text(post['user_id']),
                              Text("  ${post['user_name']}"),
                              menuPopup(docId, post['caption'], post['media'],
                                  post['user_id'])
                            ],
                          ),
                          Text("  ${post['caption']}"),
                          post['media'] != ''
                              ? Image.network(post['media'])
                              : const SizedBox(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(post['like']
                                      .toString()), // Display number of likes
                                  IconButton(
                                    icon: Icon(Icons.waving_hand),
                                    onPressed: () {
                                      // Add like functionality here
                                      _postService.addLike(docId);
                                    },
                                  ),
                                ],
                              ),
                              // Column(
                              //   children: [
                              //     Text(post['comment'].toString()), // Display number of comments
                              //     IconButton(
                              //       icon: Icon(Icons.comment),
                              //       onPressed: () {
                              //         // Add comment functionality here
                              //       },
                              //     ),
                              //   ],
                              // ),
                              // Column(
                              //   children: [
                              //     Text(post['share'].toString()), // Display number of shares
                              //     IconButton(
                              //       icon: Icon(Icons.share),
                              //       onPressed: () {
                              //         // Add share functionality here
                              //       },
                              //     ),
                              //   ],
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
  }
}