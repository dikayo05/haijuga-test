import 'package:flutter/material.dart';

import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firebase/auth_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String profilePictureUrl = '';

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  Future<void> _loadProfilePicture() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    setState(() {
      profilePictureUrl = userDoc['profile_picture'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        Text('profile'),
        Center(
            child: ClipOval(
                child: profilePictureUrl.isNotEmpty
                    ? Image.network(width: 100, height: 100, profilePictureUrl)
                    : CircularProgressIndicator())),
        Text(
          FirebaseAuth.instance.currentUser!.email.toString(),
          style: GoogleFonts.raleway(
              textStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
        ),
        ElevatedButton(
          onPressed: () async {
            await AuthService().signout(context: context);
          },
          child: const Text("Sign Out"),
        )
      ],
    ));
  }
}
