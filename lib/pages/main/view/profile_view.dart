import 'package:flutter/material.dart';

import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firebase/auth_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        Text('profile'),
        Center(
            child: ClipOval(
                child: CldImageWidget(
          publicId: 'haijuga-media/lxge14ufquonutghuvjc',
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ))),
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
