import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firebase/post_service.dart';

class AddPostView extends StatefulWidget {
  const AddPostView({super.key});

  @override
  State<AddPostView> createState() => _AddPostViewState();
}

class _AddPostViewState extends State<AddPostView> {
  final PostService firestoreService = PostService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final TextEditingController _captionController = TextEditingController();
  String? _mediaUrl;
  XFile? _image;
  bool isLoading = false;

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

  Future<void> _handleUploadPost() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (_image != null) {
        await _uploadImage();
      } else {
        _mediaUrl = '';
      }
      firestoreService.addPost(
          _firebaseAuth.currentUser!.uid, _firebaseAuth.currentUser!.email.toString(), _captionController.text, _mediaUrl!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload berhasil!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload gagal: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
        _image = null;
        _captionController.clear();
      });
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _captionController,
            decoration: InputDecoration(
              labelText: 'Caption',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            ),
            maxLines: 3,
          ),
          SizedBox(height: 20),
          _image == null
              ? Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text('No image selected.')),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(_image!.path),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.photo_library),
                label: Text('Pick Image'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
              ),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _handleUploadPost,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      ),
                      child: Text('Post'),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
