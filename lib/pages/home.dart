import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

// cloudinary
import 'package:cloudinary_flutter/image/cld_image.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final db = FirebaseFirestore.instance;
  final TextEditingController _captionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> posts = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  String _mediaUrl = '';

  XFile? _image;
  Map<String, dynamic> users = {};
  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future<void> _uploadPost() async {
// upload foto di cloudinary
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

    final post = <String, dynamic>{
      "user_id": "dfkj3kjsdf9",
      "caption": _captionController.text,
      "media": _mediaUrl,
      "created_at": DateTime.now()
    };
    db.collection("posts").add(post).then((DocumentReference doc) {
      // print('DocumentSnapshot added with ID: ${doc.id}');
    });
  }

  Future<void> fetchData() async {
    _lastDocument = null;
    posts.clear();

    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    QuerySnapshot querySnapshot;
    if (_lastDocument == null) {
      querySnapshot = await db
          .collection("posts")
          .orderBy('created_at', descending: true)
          .limit(10)
          .get();
    } else {
      querySnapshot = await db
          .collection("posts")
          .orderBy('created_at', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(10)
          .get();
    }

    if (querySnapshot.docs.isNotEmpty) {
      _lastDocument = querySnapshot.docs.last;
      posts.insertAll(
          0,
          querySnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList());
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _showPostDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button to dismiss
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

  Future<void> _editPost(String postId, String newCaption) async {
    await db.collection("posts").doc(postId).update({"caption": newCaption});
    fetchData();
  }

  Future<void> _deletePost(String postId) async {
    await db.collection("posts").doc(postId).delete();
    fetchData();
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        fetchData();
      }
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Homepage'),
              actions: [
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    fetchData();
                  },
                ),
              ],
            ),
            body: TabBarView(
              children: [
                // page 1
                Center(
                    child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          controller: _scrollController,
                          itemBuilder: (context, index) {
                            if (index == posts.length) {
                              return Center(child: CircularProgressIndicator());
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(posts[index]['user_id']),
                                    PopupMenuButton<String>(
                                      onSelected: (String result) async {
                                        if (result == 'edit') {
                                          final TextEditingController
                                              _editController =
                                              TextEditingController(
                                                  text: posts[index]
                                                      ['caption']);
                                          await showDialog<void>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('Edit Post'),
                                                content: TextField(
                                                  controller: _editController,
                                                  decoration: InputDecoration(
                                                    labelText: 'Caption',
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: const Text('Cancel'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: const Text('Save'),
                                                    onPressed: () async {
                                                      await _editPost(
                                                          posts[index]['id'],
                                                          _editController.text);
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        } else if (result == 'delete') {
                                          await _deletePost(posts[index]['id']);
                                        }
                                      },
                                      itemBuilder: (BuildContext context) =>
                                          <PopupMenuEntry<String>>[
                                        const PopupMenuItem<String>(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(posts[index]['caption']),
                                if (posts[index]['media'] != null &&
                                    posts[index]['media'].isNotEmpty)
                                  Image.network(posts[index]['media']),
                              ],
                            );
                          },
                          itemCount: posts.length + (_isLoading ? 1 : 0)),
                    ),
                  ],
                )),
                // page 2
                Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _captionController,
                      decoration: InputDecoration(
                        labelText: 'Caption',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  _image == null
                      ? const Text('No image selected.')
                      : Image.file(File(_image!.path)),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Pick Image from Gallery'),
                  ),
                  FloatingActionButton(
                      onPressed: () async {
                        await _uploadPost();
                        _captionController.clear();
                        _lastDocument = null;
                        posts.clear();
                        fetchData();
                        _showPostDialog('Post successfully uploaded!');
                      },
                      child: Text('posting')),
                ]),
                // page 3
                Center(
                    child: Column(
                  children: [
                    Text('profile'),
                    CldImageWidget(publicId: 'haijuga-app/cnga2pbepuhczzkv6tcy')
                  ],
                )),
              ],
            ),
            bottomNavigationBar: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.add)),
                Tab(icon: Icon(Icons.person))
              ],
            )));
  }
}
