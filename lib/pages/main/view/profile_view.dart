import 'package:flutter/material.dart';

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
  String fullName = '';
  String dateOfBirth = '';
  String gender = '';

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
    _loadUserProfile();
  }

  Future<void> _loadProfilePicture() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    setState(() {
      profilePictureUrl = userDoc['profile_picture'];
    });
  }

  Future<void> _loadUserProfile() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    setState(() {
      fullName = userDoc['full_name'];
      dateOfBirth = userDoc['date_of_birth'];
      gender = userDoc['gender'];
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
                    : Image.asset(
                        width: 100, height: 100, 'assets/images/avatar.png'))),
        Text(
          FirebaseAuth.instance.currentUser!.email.toString(),
          style: GoogleFonts.raleway(
              textStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
        ),
        ListTile(
          title: Text('Full Name: $fullName'),
          trailing: Icon(Icons.edit),
          onTap: () {
            // Navigate to edit full name screen
          },
        ),
        ListTile(
          title: Text('Date of Birth: $dateOfBirth'),
          trailing: Icon(Icons.edit),
          onTap: () {
            // Navigate to edit date of birth screen
          },
        ),
        ListTile(
          title: Text('Gender: $gender'),
          trailing: Icon(Icons.edit),
          onTap: () {
            // Navigate to edit gender screen
          },
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
