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
  String? _mediaUrl = '';
  XFile? _image;

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

  Widget menuPopup(String docId, String currentCaption, String currentMedia) {
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
          PopupMenuItem(
            value: 'edit',
            child: Text('Edit'),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Text('Hapus'),
          ),
          // PopupMenuItem(
          //   value: 'report',
          //   child: Text('Laporkan'),
          // ),
        ];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _postService.getPostsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List postsList = snapshot.data!.docs;
            return ListView.builder(
                itemCount: postsList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot documen = postsList[index];
                  String docId = documen.id;
                  Map<String, dynamic> post =
                      documen.data() as Map<String, dynamic>;
                  // card post
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Text(post['user_id']),
                          Text(FirebaseAuth.instance.currentUser!.email
                              .toString()),
                          menuPopup(docId, post['caption'], post['media'])
                        ],
                      ),
                      Text(post['caption']),
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
                  );
                });
          } else {
            return Text('hah kosong');
          }
        });
  }
}
