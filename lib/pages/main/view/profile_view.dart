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
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.raleway(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: ClipOval(
                child: profilePictureUrl.isNotEmpty
                    ? Image.network(profilePictureUrl, width: 100, height: 100, fit: BoxFit.cover)
                    : Image.asset('assets/images/avatar.png', width: 100, height: 100, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              FirebaseAuth.instance.currentUser!.email.toString(),
              style: GoogleFonts.raleway(
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildProfileInfo('Full Name', fullName),
            _buildProfileInfo('Date of Birth', dateOfBirth),
            _buildProfileInfo('Gender', gender),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await AuthService().signout(context: context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(String title, String value) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
      title: Text(
        '$title: $value',
        style: GoogleFonts.raleway(
          textStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
      // trailing: Icon(Icons.edit, color: Colors.blueAccent),
      onTap: () {
        // Navigate to edit screen
      },
    );
  }
}
